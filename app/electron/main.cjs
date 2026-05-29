const path = require('path');
const { app, BrowserWindow } = require('electron');
const { startApiServer } = require('../server/api.cjs');

let apiServer;
const appIcon = path.join(__dirname, 'assets', 'melodija.ico');

async function createWindow() {
  const api = await startApiServer({ port: 0 });
  apiServer = api.server;
  process.env.MELODIJA_API_BASE = `http://${api.host}:${api.port}`;

  const win = new BrowserWindow({
    width: 1180,
    height: 760,
    minWidth: 900,
    minHeight: 620,
    title: 'Melodija',
    icon: appIcon,
    backgroundColor: '#58aaa7',
    webPreferences: {
      preload: path.join(__dirname, 'preload.cjs'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  if (process.env.ELECTRON_RENDERER_URL) {
    await win.loadURL(process.env.ELECTRON_RENDERER_URL);
  } else {
    await win.loadFile(path.join(__dirname, '..', '..', 'dist', 'renderer', 'index.html'));
  }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (apiServer) {
    apiServer.close();
  }
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
