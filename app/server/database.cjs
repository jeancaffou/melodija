const fs = require('fs');
const path = require('path');
const initSqlJs = require('sql.js');

const ROOT = path.resolve(__dirname, '..', '..');

function isPackagedRuntime() {
  return Boolean(process.resourcesPath && !process.resourcesPath.includes('node_modules/electron'));
}

function resolveDbPath() {
  if (process.env.MELODIJA_DB) {
    return path.resolve(process.env.MELODIJA_DB);
  }
  const portableDir = process.env.PORTABLE_EXECUTABLE_DIR
    || (process.env.PORTABLE_EXECUTABLE_FILE ? path.dirname(process.env.PORTABLE_EXECUTABLE_FILE) : null);
  const exeDir = portableDir || (process.execPath ? path.dirname(process.execPath) : null);
  const companionDb = exeDir ? path.join(exeDir, 'melodija.db') : null;
  const resourceDb = process.resourcesPath ? path.join(process.resourcesPath, 'melodija.db') : null;

  if (isPackagedRuntime() && companionDb) {
    if (!fs.existsSync(companionDb) && resourceDb && fs.existsSync(resourceDb)) {
      fs.copyFileSync(resourceDb, companionDb);
    }
    if (fs.existsSync(companionDb)) {
      return companionDb;
    }
  }

  const candidates = [
    path.join(process.cwd(), 'melodija.db'),
    path.join(ROOT, 'melodija.db'),
    resourceDb,
    companionDb
  ].filter(Boolean);
  const found = candidates.find((candidate) => fs.existsSync(candidate));
  return found || candidates[0];
}

let storePromise;

function resetStore() {
  storePromise = null;
}

async function getStore() {
  if (!storePromise) {
    storePromise = (async () => {
      const dbPath = resolveDbPath();
      const wasmPath = require.resolve('sql.js/dist/sql-wasm.wasm');
      const SQL = await initSqlJs({ locateFile: () => wasmPath });
      if (!fs.existsSync(dbPath)) {
        throw new Error(`Database not found: ${dbPath}`);
      }
      const db = new SQL.Database(fs.readFileSync(dbPath));
      db.run('PRAGMA foreign_keys = ON');
      return new DatabaseStore(db, dbPath);
    })();
  }
  return storePromise;
}

class DatabaseStore {
  constructor(db, dbPath) {
    this.db = db;
    this.dbPath = dbPath;
  }

  rows(sql, params = []) {
    const stmt = this.db.prepare(sql);
    try {
      stmt.bind(params);
      const rows = [];
      while (stmt.step()) {
        rows.push(stmt.getAsObject());
      }
      return rows;
    } finally {
      stmt.free();
    }
  }

  get(sql, params = []) {
    return this.rows(sql, params)[0] || null;
  }

  run(sql, params = []) {
    const stmt = this.db.prepare(sql);
    try {
      stmt.run(params);
    } finally {
      stmt.free();
    }
  }

  persist() {
    fs.writeFileSync(this.dbPath, Buffer.from(this.db.export()));
  }
}

module.exports = {
  getStore,
  resetStore,
  resolveDbPath
};
