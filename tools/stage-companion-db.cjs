const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const sourceDb = path.join(root, 'melodija.db');
const releaseDir = path.join(root, 'release');
const buildDir = path.join(root, 'release', 'build');
const buildExe = path.join(buildDir, 'Melodija.exe');
const finalExe = path.join(releaseDir, 'Melodija.exe');
const sourceExe = fs.existsSync(buildExe) ? buildExe : finalExe;
const tempDir = path.join(root, '.stage-portable');
const tempExe = path.join(tempDir, 'Melodija.exe');
const tempDb = path.join(tempDir, 'melodija.db');
const targetExe = path.join(releaseDir, 'Melodija.exe');
const targetDb = path.join(releaseDir, 'melodija.db');

if (!fs.existsSync(sourceDb)) {
  throw new Error(`Missing source database: ${sourceDb}`);
}

if (!fs.existsSync(sourceExe)) {
  throw new Error(`Missing portable executable: ${sourceExe}`);
}

fs.rmSync(tempDir, { recursive: true, force: true });
fs.mkdirSync(tempDir, { recursive: true });
fs.copyFileSync(sourceExe, tempExe);
fs.copyFileSync(sourceDb, tempDb);

fs.rmSync(releaseDir, { recursive: true, force: true });
fs.mkdirSync(releaseDir, { recursive: true });
fs.renameSync(tempExe, targetExe);
fs.renameSync(tempDb, targetDb);
fs.rmSync(tempDir, { recursive: true, force: true });

const files = fs.readdirSync(releaseDir).sort();
if (files.join('\n') !== 'Melodija.exe\nmelodija.db') {
  throw new Error(`Unexpected portable release contents: ${files.join(', ')}`);
}

console.log(`Staged portable release: ${path.relative(root, releaseDir)}`);
