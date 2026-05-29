#!/usr/bin/env python3
import re
import sqlite3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
IDX = ROOT / "cobol" / "idx"
DB_PATH = ROOT / "melodija.db"


def decode_field(raw: bytes) -> str:
    return raw.decode("cp852", errors="replace").rstrip()


def parse_int(raw: bytes) -> int:
    text = raw.decode("ascii", errors="ignore").strip()
    return int(text or "0")


def fix_text(value: str, *, author_name: bool = False) -> tuple[str, list[str]]:
    fixed = value
    reasons: list[str] = []

    replacements = {
        "[": "Š",
        "\\": "Ž",
        ";": "Č",
        "]": "Đ",
        "^": "Č",
        "@": "Ž",
        "`": "'",
    }
    for old, new in replacements.items():
        if old in fixed:
            fixed = fixed.replace(old, new)
            reasons.append(f"{old}->{new}")

    if "{" in fixed:
        chars = []
        for index, char in enumerate(fixed):
            if char != "{":
                chars.append(char)
                continue
            next_char = fixed[index + 1] if index + 1 < len(fixed) else ""
            prev_char = fixed[index - 1] if index else ""
            replacement = "Š" if next_char.isupper() or prev_char.isupper() else "š"
            chars.append(replacement)
        fixed = "".join(chars)
        reasons.append("{->š/Š")

    if author_name:
        updated = re.sub(r"(?<=I)'(?=\b|-)", "Ć", fixed)
        if updated != fixed:
            fixed = updated
            reasons.append("I'->IĆ")

    return fixed.strip(), reasons


def iter_slots(path: Path, slot_size: int, record_size: int):
    data = path.read_bytes()
    for offset in range(128, len(data), slot_size):
        slot = data[offset : offset + slot_size]
        if len(slot) < 2 + record_size:
            continue
        if slot[0] != 0x40:
            continue
        yield offset, slot[2 : 2 + record_size]


def create_schema(conn: sqlite3.Connection) -> None:
    conn.executescript(
        """
        PRAGMA foreign_keys = ON;

        DROP TABLE IF EXISTS corrections;
        DROP TABLE IF EXISTS songs;
        DROP TABLE IF EXISTS authors;
        DROP TABLE IF EXISTS choirs;
        DROP TABLE IF EXISTS settings;
        DROP TABLE IF EXISTS app_meta;
        DROP TABLE IF EXISTS data_issues;

        CREATE TABLE app_meta (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        );

        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        );

        CREATE TABLE authors (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          usage_count INTEGER NOT NULL DEFAULT 0,
          type INTEGER NOT NULL DEFAULT 0,
          raw_name TEXT NOT NULL
        );

        CREATE TABLE choirs (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          short_name TEXT NOT NULL,
          raw_name TEXT NOT NULL,
          raw_short_name TEXT NOT NULL
        );

        CREATE TABLE songs (
          ownkey INTEGER PRIMARY KEY,
          choir_id INTEGER NOT NULL,
          number INTEGER NOT NULL,
          title TEXT NOT NULL,
          arranger_id INTEGER NOT NULL DEFAULT 0,
          note TEXT NOT NULL DEFAULT '',
          lyricist_id INTEGER NOT NULL DEFAULT 0,
          verse TEXT NOT NULL DEFAULT '',
          raw_title TEXT NOT NULL,
          raw_note TEXT NOT NULL,
          raw_verse TEXT NOT NULL,
          UNIQUE (choir_id, number),
          FOREIGN KEY (choir_id) REFERENCES choirs(id),
          FOREIGN KEY (arranger_id) REFERENCES authors(id),
          FOREIGN KEY (lyricist_id) REFERENCES authors(id)
        );

        CREATE TABLE corrections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          table_name TEXT NOT NULL,
          record_key TEXT NOT NULL,
          field_name TEXT NOT NULL,
          original_value TEXT NOT NULL,
          corrected_value TEXT NOT NULL,
          reason TEXT NOT NULL
        );

        CREATE TABLE data_issues (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          table_name TEXT NOT NULL,
          record_key TEXT NOT NULL,
          field_name TEXT NOT NULL,
          issue TEXT NOT NULL
        );

        CREATE INDEX idx_authors_name ON authors(name);
        CREATE INDEX idx_choirs_name ON choirs(name);
        CREATE INDEX idx_songs_title ON songs(title);
        CREATE INDEX idx_songs_verse ON songs(verse);
        CREATE INDEX idx_songs_arranger ON songs(arranger_id, choir_id, title);
        CREATE INDEX idx_songs_lyricist ON songs(lyricist_id, choir_id, title);
        CREATE INDEX idx_songs_choir_title ON songs(choir_id, title);
        """
    )


def record_correction(
    conn: sqlite3.Connection,
    table: str,
    key: str,
    field: str,
    original: str,
    corrected: str,
    reasons: list[str],
) -> None:
    if original == corrected:
        return
    conn.execute(
        """
        INSERT INTO corrections(table_name, record_key, field_name, original_value, corrected_value, reason)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (table, key, field, original, corrected, ", ".join(reasons)),
    )


def ensure_author(conn: sqlite3.Connection, author_id: int, key: str, field: str) -> None:
    if author_id == 0:
        return
    exists = conn.execute("SELECT 1 FROM authors WHERE id = ?", (author_id,)).fetchone()
    if exists:
        return
    name = f"Neznan avtor {author_id:06d}"
    conn.execute(
        "INSERT INTO authors(id, name, raw_name) VALUES (?, ?, '')",
        (author_id, name),
    )
    conn.execute(
        """
        INSERT INTO data_issues(table_name, record_key, field_name, issue)
        VALUES ('songs', ?, ?, ?)
        """,
        (key, field, f"Song references missing author id {author_id:06d}; placeholder inserted."),
    )


def migrate_choirs(conn: sqlite3.Connection) -> int:
    count = 0
    for _, record in iter_slots(IDX / "ZBORI.IND", 52, 50):
        choir_id = parse_int(record[0:2])
        raw_name = decode_field(record[2:22])
        raw_short = decode_field(record[22:27])
        name, name_reasons = fix_text(raw_name)
        short_name, short_reasons = fix_text(raw_short)
        conn.execute(
            """
            INSERT INTO choirs(id, name, short_name, raw_name, raw_short_name)
            VALUES (?, ?, ?, ?, ?)
            """,
            (choir_id, name, short_name, raw_name.strip(), raw_short.strip()),
        )
        record_correction(conn, "choirs", str(choir_id), "name", raw_name.strip(), name, name_reasons)
        record_correction(conn, "choirs", str(choir_id), "short_name", raw_short.strip(), short_name, short_reasons)
        count += 1
    return count


def migrate_authors(conn: sqlite3.Connection) -> int:
    count = 0
    for _, record in iter_slots(IDX / "AVTOR.IND", 68, 64):
        author_id = parse_int(record[0:6])
        raw_name = decode_field(record[6:26])
        usage_count = parse_int(record[26:32])
        author_type = parse_int(record[32:33])
        name, reasons = fix_text(raw_name, author_name=True)
        conn.execute(
            """
            INSERT INTO authors(id, name, usage_count, type, raw_name)
            VALUES (?, ?, ?, ?, ?)
            """,
            (author_id, name, usage_count, author_type, raw_name.strip()),
        )
        record_correction(conn, "authors", str(author_id), "name", raw_name.strip(), name, reasons)
        count += 1
    conn.execute(
        "INSERT OR IGNORE INTO authors(id, name, raw_name) VALUES (0, '', '')"
    )
    return count


def migrate_songs(conn: sqlite3.Connection) -> int:
    count = 0
    for _, record in iter_slots(IDX / "PESMI.IND", 132, 128):
        choir_id = parse_int(record[0:2])
        number = parse_int(record[2:7])
        ownkey = choir_id * 100000 + number
        raw_title = decode_field(record[7:47])
        arranger_id = parse_int(record[47:53])
        raw_note = decode_field(record[53:83])
        lyricist_id = parse_int(record[83:89])
        raw_verse = decode_field(record[89:109])

        title, title_reasons = fix_text(raw_title)
        note, note_reasons = fix_text(raw_note)
        verse, verse_reasons = fix_text(raw_verse)
        key = f"{choir_id:02d}{number:05d}"
        ensure_author(conn, arranger_id, key, "arranger_id")
        ensure_author(conn, lyricist_id, key, "lyricist_id")

        conn.execute(
            """
            INSERT INTO songs(
              ownkey, choir_id, number, title, arranger_id, note, lyricist_id,
              verse, raw_title, raw_note, raw_verse
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                ownkey,
                choir_id,
                number,
                title,
                arranger_id,
                note,
                lyricist_id,
                verse,
                raw_title.strip(),
                raw_note.strip(),
                raw_verse.strip(),
            ),
        )
        record_correction(conn, "songs", key, "title", raw_title.strip(), title, title_reasons)
        record_correction(conn, "songs", key, "note", raw_note.strip(), note, note_reasons)
        record_correction(conn, "songs", key, "verse", raw_verse.strip(), verse, verse_reasons)
        count += 1
    return count


def main() -> None:
    if DB_PATH.exists():
        DB_PATH.unlink()

    conn = sqlite3.connect(DB_PATH)
    try:
        create_schema(conn)
        choir_count = migrate_choirs(conn)
        author_count = migrate_authors(conn)
        song_count = migrate_songs(conn)
        correction_count = conn.execute("SELECT COUNT(*) FROM corrections").fetchone()[0]
        issue_count = conn.execute("SELECT COUNT(*) FROM data_issues").fetchone()[0]
        conn.executemany(
            "INSERT INTO app_meta(key, value) VALUES (?, ?)",
            [
                ("source", "Micro Focus COBOL IDX/IND"),
                ("encoding", "CP852 with legacy placeholder corrections"),
                ("choir_count", str(choir_count)),
                ("author_count", str(author_count)),
                ("song_count", str(song_count)),
                ("correction_count", str(correction_count)),
                ("issue_count", str(issue_count)),
            ],
        )
        conn.executemany(
            "INSERT INTO settings(key, value) VALUES (?, ?)",
            [
                ("ui.theme", "dos"),
                ("operator.name", "dusan"),
            ],
        )
        conn.commit()
        print(f"Created {DB_PATH}")
        print(f"Choirs: {choir_count}")
        print(f"Authors: {author_count}")
        print(f"Songs: {song_count}")
        print(f"Corrections: {correction_count}")
        print(f"Data issues: {issue_count}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
