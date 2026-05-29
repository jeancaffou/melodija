const fs = require('node:fs');
const { app, BrowserWindow } = require('electron');

const args = process.argv.slice(1).filter(Boolean);
const targetUrl = args.find((arg) => /^https?:\/\//.test(arg)) || 'http://localhost:3333/';
const output = args.find((arg) => arg.endsWith('.json')) || '/tmp/melodija-page-inspect.json';
const numberArgs = args.filter((arg) => /^\d+$/.test(arg));
const [widthArg = '1440', heightArg = '900', waitArg = '2500'] = numberArgs;
const width = Number(widthArg);
const height = Number(heightArg);
const waitMs = Number(waitArg);
const messages = [];

app.commandLine.appendSwitch('disable-gpu');
app.commandLine.appendSwitch('no-sandbox');

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

app.whenReady().then(async () => {
  const win = new BrowserWindow({
    width,
    height,
    show: false,
    backgroundColor: '#eef3f1',
    webPreferences: {
      offscreen: true,
      contextIsolation: true
    }
  });

  win.webContents.on('console-message', (_event, level, message, line, sourceId) => {
    messages.push({ level, message, line, sourceId });
  });
  win.webContents.on('render-process-gone', (_event, details) => {
    messages.push({ level: 'gone', message: JSON.stringify(details), line: 0, sourceId: '' });
  });

  await win.loadURL(targetUrl);
  await wait(waitMs);
  if (process.env.MELODIJA_INSPECT_JS) {
    await win.webContents.executeJavaScript(process.env.MELODIJA_INSPECT_JS);
    await wait(Number(process.env.MELODIJA_INSPECT_AFTER || 1200));
  }

  const snapshot = await win.webContents.executeJavaScript(`
    (() => ({
      location: location.href,
      title: document.title,
      bodyClass: document.body.className,
      editorPanelText: Array.from(document.querySelectorAll('.editor-panel')).map((el) => el.innerText),
      songFormHtml: document.querySelector('.song-form')?.outerHTML || '',
      modernActionsText: document.querySelector('.modern-actions')?.innerText || '',
      reportPreviewLength: document.querySelector('.report-preview')?.innerText.length || 0,
      tableHeaders: Array.from(document.querySelectorAll('.catalog-table th')).map((el) => el.innerText.trim()),
      tableRows: document.querySelectorAll('.catalog-table tbody tr').length,
      errors: []
    }))()
  `);

  fs.writeFileSync(output, JSON.stringify({ messages, snapshot }, null, 2));
  await app.quit();
}).catch((error) => {
  console.error(error);
  app.exit(1);
});
