const { contextBridge } = require('electron');

contextBridge.exposeInMainWorld('melodija', {
  apiBase: process.env.MELODIJA_API_BASE || ''
});
