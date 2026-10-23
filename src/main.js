const { app, BrowserWindow, ipcMain, dialog, shell } = require('electron');
const path = require('node:path');
const fs = require('node:fs/promises');
const { spawn } = require('node:child_process');
const storePath = () => path.join(app.getPath('userData'), 'library.json');
const defaults = { setupComplete: false, profile: { name: 'Player One', avatar: '', accent: '#a78bfa' }, items: [] };
async function readStore() { try { return { ...defaults, ...JSON.parse(await fs.readFile(storePath(), 'utf8')) }; } catch { return structuredClone(defaults); } }
async function writeStore(data) { const target = storePath(); await fs.mkdir(path.dirname(target), { recursive: true }); await fs.writeFile(target, JSON.stringify(data, null, 2), 'utf8'); return data; }
function createWindow() {
  const win = new BrowserWindow({ width: 1440, height: 920, minWidth: 1050, minHeight: 680, backgroundColor: '#101014', title: 'Playdeck', webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true } });
  win.loadFile(path.join(__dirname, 'index.html'));
}
app.whenReady().then(() => {
  ipcMain.handle('store:read', readStore); ipcMain.handle('store:write', (_event, value) => writeStore(value));
  ipcMain.handle('dialog:pick', async (_event, type) => {
    const props = type === 'folder' ? ['openDirectory'] : ['openFile'];
    const filters = type === 'game' ? [{ name: 'Applications', extensions: ['exe', 'bat', 'cmd', 'lnk'] }] : type === 'video' ? [{ name: 'Video', extensions: ['mp4', 'mkv', 'mov', 'avi', 'webm', 'm4v'] }] : type === 'music' ? [{ name: 'Audio', extensions: ['mp3', 'flac', 'wav', 'm4a', 'aac', 'ogg', 'wma'] }] : [];
    const result = await dialog.showOpenDialog({ properties: props, filters: filters }); return result.canceled ? null : result.filePaths[0];
  });
  ipcMain.handle('item:launch', async (_event, item) => {
    try { if (item.type === 'game' || item.type === 'app') { const target = item.path; const extension = path.extname(target).toLowerCase(); if (extension === '.lnk') { const error = await shell.openPath(target); return error ? { ok: false, error } : { ok: true }; } const child = spawn(target, [], { detached: true, stdio: 'ignore', cwd: path.dirname(target), shell: ['.bat', '.cmd'].includes(extension) }); child.unref(); return { ok: true }; }
      const error = await shell.openPath(item.path); return error ? { ok: false, error: error } : { ok: true };
    } catch (error) { return { ok: false, error: error.message }; }
  });
  ipcMain.handle('shell:reveal', (_event, target) => shell.showItemInFolder(target));
  ipcMain.handle('dialog:avatar', async () => { const result = await dialog.showOpenDialog({ properties: ['openFile'], filters: [{ name: 'Images', extensions: ['png', 'jpg', 'jpeg', 'webp', 'gif'] }] }); return result.canceled ? null : result.filePaths[0]; });
  createWindow(); app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) createWindow(); });
});
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
