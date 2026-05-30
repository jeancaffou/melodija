const http = require('http');
const fs = require('fs');
const path = require('path');
const { URL } = require('url');
const { getStore, resetStore, resolveDbPath } = require('./database.cjs');

const jsonHeaders = {
  'Content-Type': 'application/json; charset=utf-8',
  'Cache-Control': 'no-store'
};

const EDITOR_TOKEN_HEADER = 'x-melodija-editor-token';
const EDITOR_PASSWORD_TOKEN = 'dae9b02479c58ecf1922eb57c1431ea8f9f0ee2779b6f1381775efa6b02f045697cec3e33246bb4740b08c76a4069772d609dd7202b346f407bbba320433c193';

function send(res, status, payload) {
  res.writeHead(status, jsonHeaders);
  res.end(JSON.stringify(payload));
}

function isMutationRequest(req) {
  return ['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method);
}

function isEditorAuthorized(req) {
  return req.headers[EDITOR_TOKEN_HEADER] === EDITOR_PASSWORD_TOKEN;
}

function requireEditorAccess(req, res) {
  if (!isMutationRequest(req) || isEditorAuthorized(req)) return true;
  send(res, 403, { error: 'Urejevalni način je zahtevan za spremembe podatkov.' });
  return false;
}

function sendText(res, status, payload) {
  res.writeHead(status, {
    'Content-Type': 'text/plain; charset=utf-8',
    'Cache-Control': 'no-store'
  });
  res.end(payload);
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) {
    chunks.push(chunk);
  }
  const text = Buffer.concat(chunks).toString('utf8');
  return text ? JSON.parse(text) : {};
}

function intParam(value, fallback = 0) {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function likeTerm(value) {
  return `%${String(value || '').trim().toLocaleLowerCase('sl-SI')}%`;
}

function likeVariants(value, maxVariants = 24) {
  const source = String(value || '').trim().toLocaleLowerCase('sl-SI');
  if (!source) return [];
  const alternatives = {
    c: ['c', 'č', 'ć'],
    č: ['č', 'c', 'ć'],
    ć: ['ć', 'c', 'č'],
    s: ['s', 'š'],
    š: ['š', 's'],
    z: ['z', 'ž'],
    ž: ['ž', 'z'],
    d: ['d', 'đ'],
    đ: ['đ', 'd']
  };
  let variants = [''];
  for (const char of source) {
    const choices = alternatives[char] || [char];
    const next = [];
    for (const prefix of variants) {
      for (const choice of choices) {
        next.push(`${prefix}${choice}`);
      }
    }
    variants = next.slice(0, maxVariants);
  }
  const withUppercaseDiacritics = variants.flatMap((term) => [
    term,
    term
      .replaceAll('č', 'Č')
      .replaceAll('ć', 'Ć')
      .replaceAll('š', 'Š')
      .replaceAll('ž', 'Ž')
      .replaceAll('đ', 'Đ')
  ]);
  return [...new Set(withUppercaseDiacritics)].map((term) => `%${term}%`);
}

function searchFields(...fields) {
  return fields.flatMap((field) => [field, `lower(${field})`]);
}

function multiLike(fields, terms) {
  return terms
    .map(() => `(${fields.map((field) => `${field} LIKE ?`).join(' OR ')})`)
    .join(' OR ');
}

function multiLikeParams(terms, fieldCount) {
  return terms.flatMap((term) => Array(fieldCount).fill(term));
}

function normalizeText(value) {
  return String(value || '').trim();
}

function pad(value, length) {
  return String(value ?? '').padEnd(length, ' ').slice(0, length);
}

function dbBackupDir(dbPath = resolveDbPath()) {
  if (process.env.MELODIJA_BACKUP_DIR) {
    return path.resolve(process.env.MELODIJA_BACKUP_DIR);
  }
  return path.join(path.dirname(dbPath), 'backups');
}

function timestamp() {
  return new Date().toISOString().replace(/[-:]/g, '').replace(/\..+$/, '').replace('T', '-');
}

function listBackups(dbPath = resolveDbPath()) {
  const dir = dbBackupDir(dbPath);
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir)
    .filter((name) => /^melodija-\d{8}-\d{6}\.db$/.test(name))
    .map((name) => {
      const file = path.join(dir, name);
      const stat = fs.statSync(file);
      return { name, file, size: stat.size, modified: stat.mtime.toISOString() };
    })
    .sort((a, b) => b.name.localeCompare(a.name));
}

function songSelect(where = '1 = 1', order = 's.title COLLATE NOCASE, s.choir_id, s.number') {
  return `
    SELECT
      s.ownkey, s.choir_id AS choirId, s.number, s.title, s.arranger_id AS arrangerId,
      s.lyricist_id AS lyricistId, s.note, s.verse,
      c.name AS choirName, c.short_name AS choirShort,
      arranger.name AS arrangerName, lyricist.name AS lyricistName
    FROM songs s
    LEFT JOIN choirs c ON c.id = s.choir_id
    LEFT JOIN authors arranger ON arranger.id = s.arranger_id
    LEFT JOIN authors lyricist ON lyricist.id = s.lyricist_id
    WHERE ${where}
    ORDER BY ${order}
  `;
}

function refreshAuthorUsageCounts(store, ids) {
  const authorIds = [...new Set(ids.map((id) => intParam(id, 0)).filter((id) => id > 0))];
  for (const id of authorIds) {
    store.run(
      `UPDATE authors
       SET usage_count = (
         SELECT COUNT(*)
         FROM songs
         WHERE songs.arranger_id = authors.id OR songs.lyricist_id = authors.id
       )
       WHERE id = ?`,
      [id]
    );
  }
}

function authorIdsFromSong(row) {
  return [row?.arrangerId, row?.lyricistId, row?.arranger_id, row?.lyricist_id];
}

function authorReferenceCounts(store, id) {
  return store.get(
    `SELECT
       SUM(CASE WHEN arranger_id = ? THEN 1 ELSE 0 END) AS arrangedCount,
       SUM(CASE WHEN lyricist_id = ? THEN 1 ELSE 0 END) AS lyricistCount,
       COUNT(*) AS total
     FROM songs
     WHERE arranger_id = ? OR lyricist_id = ?`,
    [id, id, id, id]
  ) || { arrangedCount: 0, lyricistCount: 0, total: 0 };
}

function choirReferenceCount(store, id) {
  return store.get('SELECT COUNT(*) AS total FROM songs WHERE choir_id = ?', [id])?.total || 0;
}

function ensureAuthorExists(store, id, label, res) {
  const authorId = intParam(id, 0);
  if (!authorId) return true;
  const exists = store.get('SELECT 1 FROM authors WHERE id = ?', [authorId]);
  if (exists) return true;
  send(res, 400, { error: `${label} ne obstaja v šifrantu avtorjev.` });
  return false;
}

function compareSlovenian(left, right) {
  return String(left || '').localeCompare(String(right || ''), 'sl-SI', {
    sensitivity: 'base',
    numeric: true
  });
}

function compareNumber(left, right) {
  return intParam(left, 0) - intParam(right, 0);
}

const CATALOG_TABLES = {
  songs: {
    name: 'songs',
    label: 'Pesmi',
    rowKey: 'ownkey',
    defaultSort: 'title',
    columns: [
      { name: 'ownkey', label: 'Ključ', expr: 'ownkey', align: 'right', technical: true },
      { name: 'choirId', label: 'Zbor', expr: 'choir_id', align: 'right', technical: true },
      { name: 'number', label: 'Šifra', expr: 'number', align: 'right', technical: true },
      { name: 'title', label: 'Naziv', expr: 'title', align: 'left' },
      { name: 'arrangerId', label: 'Avtor', expr: 'arranger_id', align: 'right', technical: true },
      { name: 'lyricistId', label: 'Pesnik', expr: 'lyricist_id', align: 'right', technical: true },
      { name: 'note', label: 'Opomba', expr: 'note', align: 'left' },
      { name: 'verse', label: 'Verz', expr: 'verse', align: 'left' },
      { name: 'rawTitle', label: 'Izvorni naziv', expr: 'raw_title', align: 'left' },
      { name: 'rawNote', label: 'Izvorna opomba', expr: 'raw_note', align: 'left' },
      { name: 'rawVerse', label: 'Izvorni verz', expr: 'raw_verse', align: 'left' }
    ],
    search: ['ownkey', 'choir_id', 'number', 'title', 'arranger_id', 'lyricist_id', 'note', 'verse']
  },
  authors: {
    name: 'authors',
    label: 'Avtorji',
    rowKey: 'id',
    defaultSort: 'name',
    columns: [
      { name: 'id', label: 'Šifra', expr: 'id', align: 'right', technical: true },
      { name: 'name', label: 'Naziv', expr: 'name', align: 'left' },
      { name: 'usageCount', label: 'Skladb', expr: 'usage_count', align: 'right' },
      { name: 'type', label: 'Vrsta', expr: 'type', align: 'right', technical: true },
      { name: 'rawName', label: 'Izvorni naziv', expr: 'raw_name', align: 'left' }
    ],
    search: ['id', 'name', 'usage_count', 'type', 'raw_name']
  },
  choirs: {
    name: 'choirs',
    label: 'Zbori',
    rowKey: 'id',
    defaultSort: 'name',
    columns: [
      { name: 'id', label: 'Šifra', expr: 'id', align: 'right', technical: true },
      { name: 'name', label: 'Naziv', expr: 'name', align: 'left' },
      { name: 'shortName', label: 'Kratko', expr: 'short_name', align: 'left' },
      { name: 'rawName', label: 'Izvorni naziv', expr: 'raw_name', align: 'left' },
      { name: 'rawShortName', label: 'Izvorno kratko', expr: 'raw_short_name', align: 'left' }
    ],
    search: ['id', 'name', 'short_name', 'raw_name', 'raw_short_name']
  }
};

function publicCatalogueTable(config, count = 0) {
  return {
    name: config.name,
    label: config.label,
    rowKey: config.rowKey,
    defaultSort: config.defaultSort,
    count,
    columns: config.columns.map(({ name, label, align, technical }) => ({ name, label, align, technical: Boolean(technical) }))
  };
}

function publicSettings(rows) {
  return Object.fromEntries(
    rows
      .filter((row) => row.key !== 'ui.theme')
      .map((row) => [row.key, row.value])
  );
}

async function bootstrap(res) {
  const store = await getStore();
  const metaRows = store.rows('SELECT key, value FROM app_meta ORDER BY key');
  const settingsRows = store.rows('SELECT key, value FROM settings ORDER BY key');
  const counts = {
    songs: store.get('SELECT COUNT(*) AS count FROM songs').count,
    authors: store.get('SELECT COUNT(*) AS count FROM authors').count,
    choirs: store.get('SELECT COUNT(*) AS count FROM choirs').count,
    corrections: store.get('SELECT COUNT(*) AS count FROM corrections').count,
    issues: store.get('SELECT COUNT(*) AS count FROM data_issues').count
  };
  const operator = store.get('SELECT id, name, usage_count AS usageCount, type FROM authors WHERE id = 0');
  send(res, 200, {
    dbPath: resolveDbPath(),
    counts,
    operator,
    meta: Object.fromEntries(metaRows.map((row) => [row.key, row.value])),
    settings: publicSettings(settingsRows),
    choirs: store.rows('SELECT id, name, short_name AS shortName FROM choirs ORDER BY id')
  });
}

async function listSongs(url, res) {
  const store = await getStore();
  const query = normalizeText(url.searchParams.get('query'));
  const choirId = intParam(url.searchParams.get('choir'), 0);
  const authorText = normalizeText(url.searchParams.get('author'));
  const authorId = /^\d+$/.test(authorText) ? intParam(authorText, 0) : 0;
  const arrangerId = intParam(url.searchParams.get('arranger'), 0);
  const lyricistId = intParam(url.searchParams.get('lyricist'), 0);
  const note = normalizeText(url.searchParams.get('note'));
  const limit = Math.min(intParam(url.searchParams.get('limit'), 80), 20000);
  const offset = intParam(url.searchParams.get('offset'), 0);
  const sort = url.searchParams.get('sort') || 'title';
  const clauses = [];
  const params = [];

  if (query) {
    const terms = likeVariants(query);
    const fields = searchFields(
      's.title',
      's.verse',
      's.note',
      'arranger.name',
      'lyricist.name',
      'c.name',
      'c.short_name',
      'CAST(s.ownkey AS TEXT)',
      'CAST(s.choir_id AS TEXT)',
      'CAST(s.number AS TEXT)',
      'CAST(s.arranger_id AS TEXT)',
      'CAST(s.lyricist_id AS TEXT)'
    );
    clauses.push(`(${multiLike(fields, terms)})`);
    params.push(...multiLikeParams(terms, fields.length));
  }
  if (choirId) {
    clauses.push('s.choir_id = ?');
    params.push(choirId);
  }
  if (authorId) {
    clauses.push('(s.arranger_id = ? OR s.lyricist_id = ?)');
    params.push(authorId, authorId);
  }
  if (arrangerId) {
    clauses.push('s.arranger_id = ?');
    params.push(arrangerId);
  }
  if (lyricistId) {
    clauses.push('s.lyricist_id = ?');
    params.push(lyricistId);
  }
  if (note) {
    clauses.push('lower(s.note) = lower(?)');
    params.push(note);
  }

  const where = clauses.length ? clauses.join(' AND ') : '1 = 1';
  const order = sort === 'number'
    ? 's.choir_id, s.number'
    : 's.title COLLATE NOCASE, s.choir_id, s.number';
  const rows = store.rows(`${songSelect(where, order)} LIMIT ? OFFSET ?`, [...params, limit, offset]);
  const total = store.get(
    `SELECT COUNT(*) AS count FROM songs s
     LEFT JOIN choirs c ON c.id = s.choir_id
     LEFT JOIN authors arranger ON arranger.id = s.arranger_id
     LEFT JOIN authors lyricist ON lyricist.id = s.lyricist_id
     WHERE ${where}`,
    params
  ).count;
  send(res, 200, { rows, total, limit, offset });
}

async function listNotes(url, res) {
  const store = await getStore();
  const query = normalizeText(url.searchParams.get('query'));
  const limit = Math.min(intParam(url.searchParams.get('limit'), 80), 300);
  const params = [];
  let where = "trim(note) != ''";
  if (query) {
    const terms = likeVariants(query);
    const fields = searchFields('note');
    where += ` AND (${multiLike(fields, terms)})`;
    params.push(...multiLikeParams(terms, fields.length));
  }
  const rows = store.rows(
    `WITH note_counts AS (
       SELECT lower(note) AS noteKey, note, COUNT(*) AS variantCount
       FROM songs
       WHERE ${where}
       GROUP BY lower(note), note
     ),
     ranked_notes AS (
       SELECT
         note,
         SUM(variantCount) OVER (PARTITION BY noteKey) AS count,
         ROW_NUMBER() OVER (PARTITION BY noteKey ORDER BY variantCount DESC, note COLLATE NOCASE) AS rank
       FROM note_counts
     )
     SELECT note, count
     FROM ranked_notes
     WHERE rank = 1
     ORDER BY count DESC, note COLLATE NOCASE
     LIMIT ?`,
    [...params, limit]
  );
  send(res, 200, { rows });
}

async function getSong(ownkey, res) {
  const store = await getStore();
  const row = store.get(songSelect('s.ownkey = ?'), [ownkey]);
  if (!row) {
    send(res, 404, { error: 'Song not found' });
    return;
  }
  send(res, 200, row);
}

async function nextSongNumber(url, res) {
  const store = await getStore();
  const choirId = intParam(url.searchParams.get('choir'), 1);
  const rows = store.rows('SELECT number FROM songs WHERE choir_id = ? ORDER BY number', [choirId]);
  let nextNumber = 1;
  for (const row of rows) {
    if (row.number === nextNumber) nextNumber += 1;
    if (row.number > nextNumber) break;
  }
  send(res, 200, { choirId, nextNumber });
}

async function saveSong(req, ownkey, res) {
  const store = await getStore();
  const body = await readBody(req);
  const choirId = intParam(body.choirId, 0);
  const number = intParam(body.number, 0);
  const arrangerId = intParam(body.arrangerId, 0);
  const lyricistId = intParam(body.lyricistId, 0);
  const newOwnkey = choirId * 100000 + number;
  const affectedAuthorIds = [arrangerId, lyricistId];
  if (!choirId || !number || !normalizeText(body.title)) {
    send(res, 400, { error: 'Zbor, šifra in naziv skladbe so obvezni.' });
    return;
  }
  if (!store.get('SELECT 1 FROM choirs WHERE id = ?', [choirId])) {
    send(res, 400, { error: 'Zbor ne obstaja v šifrantu zborov.' });
    return;
  }
  if (!ensureAuthorExists(store, arrangerId, 'Avtor', res)) {
    return;
  }
  if (!ensureAuthorExists(store, lyricistId, 'Pesnik', res)) {
    return;
  }
  const previous = ownkey
    ? store.get('SELECT arranger_id AS arrangerId, lyricist_id AS lyricistId FROM songs WHERE ownkey = ?', [ownkey])
    : null;
  const target = newOwnkey !== ownkey
    ? store.get('SELECT ownkey, title FROM songs WHERE ownkey = ?', [newOwnkey])
    : null;
  if (ownkey && !previous) {
    send(res, 404, { error: 'Skladba ne obstaja.' });
    return;
  }
  if (target) {
    send(res, 409, { error: `Šifra ${String(choirId).padStart(2, '0')}${String(number).padStart(5, '0')} je že uporabljena za skladbo "${target.title}".` });
    return;
  }
  affectedAuthorIds.push(...authorIdsFromSong(previous), ...authorIdsFromSong(target));
  if (ownkey && ownkey !== newOwnkey) {
    store.run('DELETE FROM songs WHERE ownkey = ?', [ownkey]);
  }
  store.run(
    `
    INSERT OR REPLACE INTO songs(
      ownkey, choir_id, number, title, arranger_id, note, lyricist_id, verse,
      raw_title, raw_note, raw_verse
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `,
    [
      newOwnkey,
      choirId,
      number,
      normalizeText(body.title),
      arrangerId,
      normalizeText(body.note),
      lyricistId,
      normalizeText(body.verse),
      normalizeText(body.title),
      normalizeText(body.note),
      normalizeText(body.verse)
    ]
  );
  refreshAuthorUsageCounts(store, affectedAuthorIds);
  store.persist();
  await getSong(newOwnkey, res);
}

async function deleteSong(ownkey, res) {
  const store = await getStore();
  const previous = store.get('SELECT arranger_id AS arrangerId, lyricist_id AS lyricistId FROM songs WHERE ownkey = ?', [ownkey]);
  store.run('DELETE FROM songs WHERE ownkey = ?', [ownkey]);
  refreshAuthorUsageCounts(store, authorIdsFromSong(previous));
  store.persist();
  send(res, 200, { ok: true });
}

async function listAuthors(url, res) {
  const store = await getStore();
  const query = normalizeText(url.searchParams.get('query'));
  const limit = Math.min(intParam(url.searchParams.get('limit'), 80), 10000);
  const sort = url.searchParams.get('sort') || 'name';
  const params = [];
  let where = 'id != 0';
  if (query) {
    const terms = likeVariants(query);
    const fields = searchFields('name');
    where += ` AND (${multiLike(fields, terms)} OR printf("%06d", id) LIKE ?)`;
    params.push(...multiLikeParams(terms, fields.length), `%${query}%`);
  }
  const order = sort === 'id' || sort === 'number'
    ? 'id'
    : 'name COLLATE NOCASE, id';
  const rows = store.rows(
    `SELECT id, name, usage_count AS usageCount, type, raw_name AS rawName
     FROM authors WHERE ${where}
     ORDER BY ${order} LIMIT ?`,
    [...params, limit]
  );
  send(res, 200, { rows });
}

async function nextAuthorId(res) {
  const store = await getStore();
  const rows = store.rows('SELECT id FROM authors WHERE id != 0 ORDER BY id');
  let nextId = 1;
  for (const row of rows) {
    if (row.id === nextId) nextId += 1;
    if (row.id > nextId) break;
  }
  send(res, 200, { nextId });
}

async function saveAuthor(req, id, res) {
  const store = await getStore();
  const body = await readBody(req);
  const authorId = id || intParam(body.id, 0);
  const name = normalizeText(body.name);
  if (!authorId || !name) {
    send(res, 400, { error: 'Author id and name are required.' });
    return;
  }
  store.run(
    `INSERT OR REPLACE INTO authors(id, name, usage_count, type, raw_name)
     VALUES (?, ?, COALESCE((SELECT usage_count FROM authors WHERE id = ?), 0), ?, ?)`,
    [authorId, name, authorId, intParam(body.type, 0), normalizeText(body.rawName || name)]
  );
  store.persist();
  send(res, 200, store.get('SELECT id, name, usage_count AS usageCount, type, raw_name AS rawName FROM authors WHERE id = ?', [authorId]));
}

async function deleteAuthor(id, res) {
  const store = await getStore();
  if (!id) {
    send(res, 400, { error: 'Šifra avtorja je obvezna.' });
    return;
  }
  const author = store.get('SELECT id, name FROM authors WHERE id = ?', [id]);
  if (!author) {
    send(res, 404, { error: 'Avtor ne obstaja.' });
    return;
  }
  if (id === 0) {
    send(res, 409, { error: 'Vnašalca ni mogoče izbrisati.' });
    return;
  }
  const references = authorReferenceCounts(store, id);
  if (references.total) {
    send(res, 409, {
      error: `Avtorja ni mogoče izbrisati, ker je povezan s ${references.total} skladbami (${references.arrangedCount || 0} kot avtor, ${references.lyricistCount || 0} kot pesnik).`
    });
    return;
  }
  store.run('DELETE FROM authors WHERE id = ?', [id]);
  store.persist();
  send(res, 200, { ok: true });
}

async function listChoirs(url, res) {
  const store = await getStore();
  const sort = url.searchParams.get('sort') || 'id';
  const order = sort === 'name' || sort === 'alpha'
    ? 'name COLLATE NOCASE, id'
    : 'id';
  send(res, 200, {
    rows: store.rows(`SELECT id, name, short_name AS shortName, raw_name AS rawName FROM choirs ORDER BY ${order}`)
  });
}

async function quickSearch(url, res) {
  const store = await getStore();
  const query = normalizeText(url.searchParams.get('query'));
  const limit = Math.min(intParam(url.searchParams.get('limit'), 24), 60);
  if (!query) {
    send(res, 200, { rows: [] });
    return;
  }

  const perGroup = Math.max(6, Math.ceil(limit / 3));
  const textTerms = likeVariants(query);
  const codeTerm = `%${query}%`;
  const songFields = searchFields(
    's.title',
    's.verse',
    's.note',
    'arranger.name',
    'lyricist.name',
    'c.name',
    'c.short_name'
  );
  const songRows = store.rows(
    `${songSelect(`(
      ${multiLike(songFields, textTerms)}
      OR printf('%05d', s.number) LIKE ? OR printf('%02d', s.choir_id) LIKE ?
    )`)} LIMIT ?`,
    [...multiLikeParams(textTerms, songFields.length), codeTerm, codeTerm, perGroup]
  ).map((row) => ({
    id: `song:${row.ownkey}`,
    type: 'song',
    label: row.title,
    detail: `${row.choirShort || row.choirId} ${String(row.number).padStart(5, '0')}  ${row.arrangerName || ''}`,
    item: row
  }));

  const authorRows = store.rows(
    `SELECT id, name, usage_count AS usageCount, type, raw_name AS rawName
     FROM authors
     WHERE id != 0 AND (${multiLike(searchFields('name'), textTerms)} OR printf('%06d', id) LIKE ?)
     ORDER BY name COLLATE NOCASE, id
     LIMIT ?`,
    [...multiLikeParams(textTerms, searchFields('name').length), codeTerm, perGroup]
  ).map((row) => ({
    id: `author:${row.id}`,
    type: 'author',
    label: row.name,
    detail: `${String(row.id).padStart(6, '0')}  ${row.usageCount || 0} skladb`,
    item: row
  }));

  const choirRows = store.rows(
    `SELECT id, name, short_name AS shortName, raw_name AS rawName
     FROM choirs
     WHERE ${multiLike(searchFields('name', 'short_name'), textTerms)} OR printf('%02d', id) LIKE ?
     ORDER BY id
     LIMIT ?`,
    [...multiLikeParams(textTerms, searchFields('name', 'short_name').length), codeTerm, perGroup]
  ).map((row) => ({
    id: `choir:${row.id}`,
    type: 'choir',
    label: row.name,
    detail: `${String(row.id).padStart(2, '0')}  ${row.shortName || ''}`,
    item: row
  }));

  const noteRows = store.rows(
    `WITH note_counts AS (
       SELECT lower(note) AS noteKey, note, COUNT(*) AS variantCount
       FROM songs
       WHERE trim(note) != '' AND (${multiLike(searchFields('note'), textTerms)})
       GROUP BY lower(note), note
     ),
     ranked_notes AS (
       SELECT
         note,
         SUM(variantCount) OVER (PARTITION BY noteKey) AS count,
         ROW_NUMBER() OVER (PARTITION BY noteKey ORDER BY variantCount DESC, note COLLATE NOCASE) AS rank
       FROM note_counts
     )
     SELECT note, count
     FROM ranked_notes
     WHERE rank = 1
     ORDER BY count DESC, note COLLATE NOCASE
     LIMIT ?`,
    [...multiLikeParams(textTerms, searchFields('note').length), perGroup]
  ).map((row) => ({
    id: `note:${row.note}`,
    type: 'note',
    label: row.note,
    detail: `${row.count} skladb`,
    item: row
  }));

  send(res, 200, { rows: [...noteRows, ...songRows, ...authorRows, ...choirRows].slice(0, limit) });
}

async function nextChoirId(res) {
  const store = await getStore();
  const rows = store.rows('SELECT id FROM choirs WHERE id != 0 ORDER BY id');
  let nextId = 1;
  for (const row of rows) {
    if (row.id === nextId) nextId += 1;
    if (row.id > nextId) break;
  }
  send(res, 200, { nextId });
}

async function saveChoir(req, id, res) {
  const store = await getStore();
  const body = await readBody(req);
  const choirId = id || intParam(body.id, 0);
  if (!choirId || !normalizeText(body.name)) {
    send(res, 400, { error: 'Šifra in naziv zbora sta obvezna.' });
    return;
  }
  store.run(
    `INSERT OR REPLACE INTO choirs(id, name, short_name, raw_name, raw_short_name)
     VALUES (?, ?, ?, ?, ?)`,
    [
      choirId,
      normalizeText(body.name),
      normalizeText(body.shortName),
      normalizeText(body.rawName || body.name),
      normalizeText(body.rawShortName || body.shortName)
    ]
  );
  store.persist();
  send(res, 200, store.get('SELECT id, name, short_name AS shortName, raw_name AS rawName FROM choirs WHERE id = ?', [choirId]));
}

async function deleteChoir(id, res) {
  const store = await getStore();
  if (!id) {
    send(res, 400, { error: 'Šifra zbora je obvezna.' });
    return;
  }
  const choir = store.get('SELECT id, name FROM choirs WHERE id = ?', [id]);
  if (!choir) {
    send(res, 404, { error: 'Zbor ne obstaja.' });
    return;
  }
  const references = choirReferenceCount(store, id);
  if (references) {
    send(res, 409, { error: `Zbora ni mogoče izbrisati, ker vsebuje ${references} skladb.` });
    return;
  }
  store.run('DELETE FROM choirs WHERE id = ?', [id]);
  store.persist();
  send(res, 200, { ok: true });
}

function formatSongLine(row) {
  return [
    pad(row.choirShort || '', 8),
    String(row.number).padStart(5, '0'),
    pad(row.title, 42),
    pad(row.arrangerName || '', 22),
    pad(row.note || '', 30)
  ].join(' ');
}

function reportHeader(title, filterText) {
  const now = new Date();
  const stamp = now.toLocaleString('sl-SI');
  return [
    'COMFIN VINKO STEGEL',
    `MELODIJA 5.0  ${stamp}`,
    title,
    filterText,
    ''.padEnd(118, '-')
  ].filter(Boolean);
}

async function report(url, res) {
  const store = await getStore();
  const type = url.pathname.split('/').pop();
  const choirId = intParam(url.searchParams.get('choir'), 0);
  const authorText = normalizeText(url.searchParams.get('author'));
  const authorId = /^\d+$/.test(authorText) ? intParam(authorText, 0) : 0;
  const order = url.searchParams.get('order') === 'number' ? 'number' : 'alpha';
  const lines = [];

  if (type === 'authors') {
    const params = [];
    let where = 'id != 0';
    if (authorText) {
      const terms = likeVariants(authorText);
      const fields = searchFields('name', 'raw_name', 'CAST(id AS TEXT)');
      where += ` AND (${multiLike(fields, terms)})`;
      params.push(...multiLikeParams(terms, fields.length));
    }
    const rows = store.rows(
      `SELECT id, name, usage_count AS usageCount, type FROM authors WHERE ${where}
       ORDER BY ${order === 'number' ? 'id' : 'name COLLATE NOCASE, id'}`,
      params
    ).sort((left, right) => (
      order === 'number'
        ? compareNumber(left.id, right.id)
        : compareSlovenian(left.name, right.name) || compareNumber(left.id, right.id)
    ));
    lines.push(...reportHeader('Seznam AVTORJEV', [
      order === 'number' ? 'Po šifrah' : 'Abecedni',
      authorText ? `Avtor: ${authorText}` : ''
    ].filter(Boolean).join(' | ')));
    rows.forEach((row) => lines.push(`${String(row.id).padStart(6, '0')} ${row.name}`));
    send(res, 200, { title: 'Seznam AVTORJEV', count: rows.length, lines, rows });
    return;
  }

  if (type === 'choirs') {
    const params = [];
    let where = '1 = 1';
    if (authorText) {
      const terms = likeVariants(authorText);
      const fields = searchFields('name', 'short_name', 'raw_name', 'raw_short_name', 'CAST(id AS TEXT)');
      where = `(${multiLike(fields, terms)})`;
      params.push(...multiLikeParams(terms, fields.length));
    }
    const rows = store.rows(
      `SELECT id, name, short_name AS shortName FROM choirs
       WHERE ${where}
       ORDER BY ${order === 'number' ? 'id' : 'name COLLATE NOCASE, id'}`,
      params
    ).sort((left, right) => (
      order === 'number'
        ? compareNumber(left.id, right.id)
        : compareSlovenian(left.name, right.name) || compareNumber(left.id, right.id)
    ));
    lines.push(...reportHeader('Seznam ZBOROV', [
      order === 'number' ? 'Po šifrah' : 'Abecedni',
      authorText ? `Zbor: ${authorText}` : ''
    ].filter(Boolean).join(' | ')));
    rows.forEach((row) => lines.push(`${String(row.id).padStart(3, '0')} ${pad(row.name, 30)} ${row.shortName || ''}`));
    send(res, 200, { title: 'Seznam ZBOROV', count: rows.length, lines, rows });
    return;
  }

  if (type === 'songs') {
    const clauses = [];
    const params = [];
    if (choirId) {
      clauses.push('s.choir_id = ?');
      params.push(choirId);
    }
    if (authorText) {
      const terms = likeVariants(authorText);
      const fields = searchFields(
        's.title',
        's.verse',
        's.note',
        'arranger.name',
        'lyricist.name',
        'c.name',
        'c.short_name',
        'CAST(s.ownkey AS TEXT)',
        'CAST(s.choir_id AS TEXT)',
        'CAST(s.number AS TEXT)',
        'CAST(s.arranger_id AS TEXT)',
        'CAST(s.lyricist_id AS TEXT)'
      );
      clauses.push(`(${multiLike(fields, terms)})`);
      params.push(...multiLikeParams(terms, fields.length));
    }
    const rows = store.rows(
      songSelect(clauses.length ? clauses.join(' AND ') : '1 = 1', order === 'number' ? 's.choir_id, s.number' : 's.title COLLATE NOCASE, s.choir_id, s.number'),
      params
    ).sort((left, right) => (
      order === 'number'
        ? compareNumber(left.choirId, right.choirId) || compareNumber(left.number, right.number)
        : compareSlovenian(left.title, right.title) || compareNumber(left.choirId, right.choirId) || compareNumber(left.number, right.number)
    ));
    const filter = [
      choirId ? `Zbor: ${rows[0]?.choirName || choirId}` : 'Zbor: VSI',
      authorText ? `Išči: ${authorText}` : ''
    ].filter(Boolean).join(' | ');
    lines.push(...reportHeader('Seznam PESMI', filter));
    lines.push('Zbor     Šifra Skladba                                    Avtor                  Opomba');
    rows.forEach((row) => lines.push(formatSongLine(row)));
    send(res, 200, { title: 'Seznam PESMI', count: rows.length, lines, rows });
    return;
  }

  const authorField = type === 'by-lyricist' ? 's.lyricist_id' : 's.arranger_id';
  const authorAlias = type === 'by-lyricist' ? 'lyricist' : 'arranger';
  const title = type === 'by-lyricist' ? 'Skladbe po PESNIKIH-ZBORIH' : 'Skladbe po AVTORJIH-ZBORIH';
  const clauses = [`${authorField} != 0`];
  const params = [];
  if (choirId) {
    clauses.push('s.choir_id = ?');
    params.push(choirId);
  }
  if (authorId) {
    clauses.push(`${authorField} = ?`);
    params.push(authorId);
  } else if (authorText) {
    const terms = likeVariants(authorText);
    const fields = searchFields(`${authorAlias}.name`, `CAST(${authorField} AS TEXT)`);
    clauses.push(`(${multiLike(fields, terms)})`);
    params.push(...multiLikeParams(terms, fields.length));
  }
  const rows = store.rows(
    songSelect(clauses.join(' AND '), `${authorAlias}.name COLLATE NOCASE, ${authorField}, s.choir_id, s.title COLLATE NOCASE`),
    params
  ).sort((left, right) => {
    const leftName = type === 'by-lyricist' ? left.lyricistName : left.arrangerName;
    const rightName = type === 'by-lyricist' ? right.lyricistName : right.arrangerName;
    const leftId = type === 'by-lyricist' ? left.lyricistId : left.arrangerId;
    const rightId = type === 'by-lyricist' ? right.lyricistId : right.arrangerId;
    return compareSlovenian(leftName, rightName)
      || compareNumber(leftId, rightId)
      || compareNumber(left.choirId, right.choirId)
      || compareSlovenian(left.title, right.title)
      || compareNumber(left.number, right.number);
  });
  lines.push(...reportHeader(title, choirId ? `Zbor: ${rows[0]?.choirName || choirId}` : 'VSI ZBORI'));
  let lastAuthor = null;
  let lastChoir = null;
  rows.forEach((row) => {
    const activeAuthor = type === 'by-lyricist' ? row.lyricistName : row.arrangerName;
    const activeAuthorId = type === 'by-lyricist' ? row.lyricistId : row.arrangerId;
    if (lastAuthor !== activeAuthorId) {
      lines.push('');
      lines.push(`${String(activeAuthorId).padStart(6, '0')} ${activeAuthor || ''}`);
      lastAuthor = activeAuthorId;
      lastChoir = null;
    }
    if (lastChoir !== row.choirId) {
      lines.push(`  ${row.choirName}`);
      lastChoir = row.choirId;
    }
    lines.push(`    ${String(row.number).padStart(5, '0')} ${pad(row.title, 42)} ${row.note || ''}`);
  });
  send(res, 200, { title, count: rows.length, lines, rows });
}

async function setSetting(req, res) {
  const store = await getStore();
  const body = await readBody(req);
  if (!body.key) {
    send(res, 400, { error: 'Setting key is required.' });
    return;
  }
  store.run('INSERT OR REPLACE INTO settings(key, value) VALUES (?, ?)', [body.key, String(body.value ?? '')]);
  store.persist();
  send(res, 200, { ok: true });
}

async function maintenanceInfo(res) {
  const store = await getStore();
  const dbPath = resolveDbPath();
  const settingsRows = store.rows('SELECT key, value FROM settings ORDER BY key');
  send(res, 200, {
    dbPath,
    backupDir: dbBackupDir(dbPath),
    backups: listBackups(dbPath),
    operator: store.get('SELECT id, name, usage_count AS usageCount, type FROM authors WHERE id = 0'),
    counts: {
      songs: store.get('SELECT COUNT(*) AS count FROM songs').count,
      authors: store.get('SELECT COUNT(*) AS count FROM authors').count,
      choirs: store.get('SELECT COUNT(*) AS count FROM choirs').count
    },
    settings: publicSettings(settingsRows)
  });
}

async function backupDatabase(res) {
  const store = await getStore();
  store.persist();
  const dbPath = resolveDbPath();
  const dir = dbBackupDir(dbPath);
  fs.mkdirSync(dir, { recursive: true });
  const file = path.join(dir, `melodija-${timestamp()}.db`);
  fs.copyFileSync(dbPath, file);
  send(res, 200, {
    ok: true,
    message: `Shranjeno: ${file}`,
    backup: { file, name: path.basename(file), size: fs.statSync(file).size },
    backups: listBackups(dbPath)
  });
}

async function downloadDatabase(req, res) {
  if (!isEditorAuthorized(req)) {
    send(res, 403, { error: 'Urejevalni način je zahtevan za prenos baze.' });
    return;
  }
  const store = await getStore();
  store.persist();
  const dbPath = resolveDbPath();
  fs.stat(dbPath, (error, stat) => {
    if (error || !stat.isFile()) {
      send(res, 404, { error: 'Baza melodija.db ni najdena.' });
      return;
    }
    res.writeHead(200, {
      'Content-Type': 'application/octet-stream',
      'Content-Disposition': 'attachment; filename="melodija.db"',
      'Content-Length': stat.size,
      'Cache-Control': 'no-store'
    });
    fs.createReadStream(dbPath).pipe(res);
  });
}

async function restoreDatabase(res) {
  const dbPath = resolveDbPath();
  const [latest] = listBackups(dbPath);
  if (!latest) {
    send(res, 404, { error: 'Ni varnostne kopije za vračanje podatkov.' });
    return;
  }
  fs.copyFileSync(latest.file, dbPath);
  resetStore();
  send(res, 200, {
    ok: true,
    message: `Vrnjeno: ${latest.file}`,
    restored: latest
  });
}

async function rebuildDatabase(res) {
  const store = await getStore();
  store.run(`
    UPDATE authors
    SET usage_count = (
      SELECT COUNT(*)
      FROM songs
      WHERE songs.arranger_id = authors.id OR songs.lyricist_id = authors.id
    )
  `);
  store.run('REINDEX');
  store.run('VACUUM');
  store.persist();
  send(res, 200, {
    ok: true,
    message: 'Baza je obnovljena.',
    counts: {
      songs: store.get('SELECT COUNT(*) AS count FROM songs').count,
      authors: store.get('SELECT COUNT(*) AS count FROM authors').count,
      choirs: store.get('SELECT COUNT(*) AS count FROM choirs').count
    }
  });
}

async function setAppClock(req, res) {
  const store = await getStore();
  const body = await readBody(req);
  const appDate = normalizeText(body.date);
  const appTime = normalizeText(body.time);
  if (appDate) {
    store.run('INSERT OR REPLACE INTO settings(key, value) VALUES (?, ?)', ['app.date', appDate]);
  }
  if (appTime) {
    store.run('INSERT OR REPLACE INTO settings(key, value) VALUES (?, ?)', ['app.time', appTime]);
  }
  store.persist();
  send(res, 200, { ok: true, date: appDate, time: appTime, message: 'Datum/ura aplikacije shranjena.' });
}

async function setOperator(req, res) {
  const store = await getStore();
  const body = await readBody(req);
  const operator = normalizeText(body.operator || body.name || 'dusan');
  store.run('INSERT OR REPLACE INTO settings(key, value) VALUES (?, ?)', ['operator.name', operator]);
  const current = store.get('SELECT usage_count AS usageCount, type FROM authors WHERE id = 0') || { usageCount: 0, type: 1 };
  store.run(
    `INSERT OR REPLACE INTO authors(id, name, usage_count, type, raw_name)
     VALUES (0, ?, ?, ?, ?)`,
    [operator, intParam(current.usageCount, 0), intParam(current.type, 1), operator]
  );
  store.persist();
  send(res, 200, { ok: true, operator, message: `Vnašalec: ${operator}` });
}

async function corrections(url, res) {
  const store = await getStore();
  const limit = Math.min(intParam(url.searchParams.get('limit'), 200), 1000);
  send(res, 200, {
    rows: store.rows(
      `SELECT table_name AS tableName, record_key AS recordKey, field_name AS fieldName,
              original_value AS originalValue, corrected_value AS correctedValue, reason
       FROM corrections ORDER BY id LIMIT ?`,
      [limit]
    )
  });
}

async function catalogueTables(res) {
  const store = await getStore();
  const tables = Object.values(CATALOG_TABLES).map((config) => {
    const count = store.get(`SELECT COUNT(*) AS count FROM ${config.name}`)?.count || 0;
    return publicCatalogueTable(config, count);
  });
  send(res, 200, { tables });
}

async function catalogueTableRows(tableName, url, res) {
  const config = CATALOG_TABLES[tableName];
  if (!config) {
    send(res, 404, { error: 'Catalogue table not found.' });
    return;
  }

  const store = await getStore();
  const query = normalizeText(url.searchParams.get('query'));
  const limit = Math.min(intParam(url.searchParams.get('limit'), 50), 1000);
  const offset = Math.max(0, intParam(url.searchParams.get('offset'), 0));
  const sortBy = normalizeText(url.searchParams.get('sortBy')) || config.defaultSort;
  const descending = ['1', 'true', 'yes', 'desc'].includes(String(url.searchParams.get('descending') || '').toLowerCase());
  const sortColumn = config.columns.find((column) => column.name === sortBy) || config.columns.find((column) => column.name === config.defaultSort);
  const whereParams = [];
  let where = '1 = 1';

  if (query) {
    const terms = likeVariants(query);
    const fields = config.search.flatMap((field) => [`CAST(${field} AS TEXT)`, `lower(CAST(${field} AS TEXT))`]);
    where = `(${multiLike(fields, terms)})`;
    whereParams.push(...multiLikeParams(terms, fields.length));
  }

  const selectColumns = config.columns.map((column) => `${column.expr} AS ${column.name}`).join(', ');
  const orderDirection = descending ? 'DESC' : 'ASC';
  const rows = store.rows(
    `SELECT ${selectColumns}
     FROM ${config.name}
     WHERE ${where}
     ORDER BY ${sortColumn.expr} ${orderDirection}
     LIMIT ? OFFSET ?`,
    [...whereParams, limit, offset]
  );
  const total = store.get(`SELECT COUNT(*) AS count FROM ${config.name} WHERE ${where}`, whereParams)?.count || 0;

  send(res, 200, {
    table: publicCatalogueTable(config, total),
    rows,
    total,
    limit,
    offset,
    sortBy: sortColumn.name,
    descending
  });
}

async function handleApiRequest(req, res) {
  try {
    const url = new URL(req.url, 'http://127.0.0.1');
    if (!url.pathname.startsWith('/api')) {
      return false;
    }
    if (!requireEditorAccess(req, res)) {
      return true;
    }

    if (req.method === 'GET' && url.pathname === '/api/health') {
      send(res, 200, { ok: true, dbPath: resolveDbPath() });
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/bootstrap') {
      await bootstrap(res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/songs') {
      await listSongs(url, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/songs/next-number') {
      await nextSongNumber(url, res);
      return true;
    }
    const songMatch = url.pathname.match(/^\/api\/songs\/(\d+)$/);
    if (songMatch && req.method === 'GET') {
      await getSong(Number(songMatch[1]), res);
      return true;
    }
    if (songMatch && (req.method === 'PUT' || req.method === 'POST')) {
      await saveSong(req, Number(songMatch[1]), res);
      return true;
    }
    if (url.pathname === '/api/songs' && req.method === 'POST') {
      await saveSong(req, 0, res);
      return true;
    }
    if (songMatch && req.method === 'DELETE') {
      await deleteSong(Number(songMatch[1]), res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/authors') {
      await listAuthors(url, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/authors/next-id') {
      await nextAuthorId(res);
      return true;
    }
    const authorMatch = url.pathname.match(/^\/api\/authors\/(\d+)$/);
    if ((url.pathname === '/api/authors' || authorMatch) && (req.method === 'POST' || req.method === 'PUT')) {
      await saveAuthor(req, authorMatch ? Number(authorMatch[1]) : 0, res);
      return true;
    }
    if (authorMatch && req.method === 'DELETE') {
      await deleteAuthor(Number(authorMatch[1]), res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/choirs') {
      await listChoirs(url, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/search') {
      await quickSearch(url, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/notes') {
      await listNotes(url, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/choirs/next-id') {
      await nextChoirId(res);
      return true;
    }
    const choirMatch = url.pathname.match(/^\/api\/choirs\/(\d+)$/);
    if ((url.pathname === '/api/choirs' || choirMatch) && (req.method === 'POST' || req.method === 'PUT')) {
      await saveChoir(req, choirMatch ? Number(choirMatch[1]) : 0, res);
      return true;
    }
    if (choirMatch && req.method === 'DELETE') {
      await deleteChoir(Number(choirMatch[1]), res);
      return true;
    }
    if (req.method === 'GET' && url.pathname.startsWith('/api/reports/')) {
      await report(url, res);
      return true;
    }
    if (req.method === 'POST' && url.pathname === '/api/settings') {
      await setSetting(req, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/maintenance') {
      await maintenanceInfo(res);
      return true;
    }
    if (req.method === 'POST' && url.pathname === '/api/maintenance/backup') {
      await backupDatabase(res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/maintenance/download-db') {
      await downloadDatabase(req, res);
      return true;
    }
    if (req.method === 'POST' && url.pathname === '/api/maintenance/restore') {
      await restoreDatabase(res);
      return true;
    }
    if (req.method === 'POST' && url.pathname === '/api/maintenance/rebuild') {
      await rebuildDatabase(res);
      return true;
    }
    if (req.method === 'POST' && url.pathname === '/api/maintenance/app-clock') {
      await setAppClock(req, res);
      return true;
    }
    if (req.method === 'POST' && url.pathname === '/api/maintenance/operator') {
      await setOperator(req, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/corrections') {
      await corrections(url, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/database/tables') {
      await catalogueTables(res);
      return true;
    }
    const databaseTableMatch = url.pathname.match(/^\/api\/database\/([a-z_]+)$/);
    if (databaseTableMatch && req.method === 'GET') {
      await catalogueTableRows(databaseTableMatch[1], url, res);
      return true;
    }
    if (req.method === 'GET' && url.pathname === '/api/export/report.txt') {
      await report(url, {
        writeHead(status) {
          this.status = status;
        },
        end(text) {
          sendText(res, this.status || 200, text);
        }
      });
      return true;
    }
    send(res, 404, { error: 'API route not found' });
    return true;
  } catch (error) {
    send(res, 500, { error: error.message, stack: process.env.NODE_ENV === 'development' ? error.stack : undefined });
    return true;
  }
}

function startApiServer(options = {}) {
  const port = options.port ?? 0;
  const host = options.host || '127.0.0.1';
  const server = http.createServer(async (req, res) => {
    const handled = await handleApiRequest(req, res);
    if (!handled) {
      send(res, 404, { error: 'Not found' });
    }
  });
  return new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(port, host, () => {
      const address = server.address();
      resolve({ server, port: address.port, host });
    });
  });
}

module.exports = {
  handleApiRequest,
  startApiServer
};
