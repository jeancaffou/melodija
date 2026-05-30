const fs = require('fs');
const http = require('http');
const path = require('path');
const { handleApiRequest } = require('./api.cjs');

const ROOT = path.resolve(__dirname, '..', '..');
const STATIC_ROOT = path.resolve(process.env.MELODIJA_STATIC_ROOT || path.join(ROOT, 'dist', 'renderer'));
const HOST = process.env.HOST || '0.0.0.0';
const PORT = Number.parseInt(process.env.PORT || '3333', 10);

const contentTypes = {
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.ico': 'image/x-icon',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.map': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
  '.wasm': 'application/wasm',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2'
};

function sendStatus(res, status, message) {
  res.writeHead(status, {
    'Content-Type': 'text/plain; charset=utf-8',
    'Cache-Control': 'no-store'
  });
  res.end(message);
}

function isInsideStaticRoot(filePath) {
  const relative = path.relative(STATIC_ROOT, filePath);
  return relative === '' || (!relative.startsWith('..') && !path.isAbsolute(relative));
}

function staticPathFromUrl(urlPath) {
  const decodedPath = decodeURIComponent(urlPath.split('/').filter(Boolean).join('/'));
  const requested = path.resolve(STATIC_ROOT, decodedPath);
  if (!isInsideStaticRoot(requested)) return null;
  return requested;
}

function isDatabaseRequest(urlPath) {
  return /\.(db|sqlite|sqlite3)$/i.test(urlPath);
}

function serveFile(res, filePath) {
  const extension = path.extname(filePath).toLowerCase();
  if (extension === '.db' || extension === '.sqlite' || extension === '.sqlite3') {
    sendStatus(res, 404, 'Not found');
    return;
  }

  fs.stat(filePath, (statError, stat) => {
    if (statError || !stat.isFile()) {
      sendStatus(res, 404, 'Not found');
      return;
    }

    res.writeHead(200, {
      'Content-Type': contentTypes[extension] || 'application/octet-stream',
      'Content-Length': stat.size,
      'Cache-Control': filePath.endsWith('index.html')
        ? 'no-store'
        : 'public, max-age=31536000, immutable'
    });
    fs.createReadStream(filePath).pipe(res);
  });
}

async function handleRequest(req, res) {
  if (req.url?.startsWith('/api')) {
    await handleApiRequest(req, res);
    return;
  }

  if (req.method !== 'GET' && req.method !== 'HEAD') {
    sendStatus(res, 405, 'Method not allowed');
    return;
  }

  const url = new URL(req.url || '/', `http://${req.headers.host || 'localhost'}`);
  if (isDatabaseRequest(url.pathname)) {
    sendStatus(res, 404, 'Not found');
    return;
  }

  const requested = staticPathFromUrl(url.pathname);
  if (!requested) {
    sendStatus(res, 404, 'Not found');
    return;
  }

  fs.stat(requested, (statError, stat) => {
    const filePath = !statError && stat.isFile()
      ? requested
      : path.join(STATIC_ROOT, 'index.html');
    serveFile(res, filePath);
  });
}

if (!fs.existsSync(path.join(STATIC_ROOT, 'index.html'))) {
  console.error(`SPA build not found at ${STATIC_ROOT}. Run npm run build:renderer first.`);
  process.exit(1);
}

http.createServer((req, res) => {
  handleRequest(req, res).catch((error) => {
    console.error(error);
    sendStatus(res, 500, 'Internal server error');
  });
}).listen(PORT, HOST, () => {
  console.log(`Melodija SPA listening on http://${HOST}:${PORT}`);
  console.log(`Static root: ${STATIC_ROOT}`);
});
