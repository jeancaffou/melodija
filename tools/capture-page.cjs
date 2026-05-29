const fs = require('node:fs');
const { app, BrowserWindow } = require('electron');

const args = process.argv.slice(1).filter(Boolean);
const targetUrl = args.find((arg) => /^https?:\/\//.test(arg)) || 'http://localhost:3333/';
const output = args.find((arg) => arg.endsWith('.png')) || '/tmp/melodija-page.png';
const numberArgs = args.filter((arg) => /^\d+$/.test(arg));
const [widthArg = '700', heightArg = '412', waitArg = '1500'] = numberArgs;
const width = Number(widthArg);
const height = Number(heightArg);
const waitMs = Number(waitArg);

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
    backgroundColor: '#55abaa',
    webPreferences: {
      offscreen: true,
      contextIsolation: true
    }
  });

  await win.loadURL(targetUrl);
  await wait(waitMs);
  if (process.env.MELODIJA_CAPTURE_JS) {
    await win.webContents.executeJavaScript(process.env.MELODIJA_CAPTURE_JS);
    await wait(Number(process.env.MELODIJA_CAPTURE_AFTER || 1200));
  }

  const image = await win.webContents.capturePage();
  fs.writeFileSync(output, image.toPNG());

  await app.quit();
}).catch((error) => {
  console.error(error);
  app.exit(1);
});
