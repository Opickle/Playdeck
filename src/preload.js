const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('playdeck', { read: () => ipcRenderer.invoke('store:read'), save: (data) => ipcRenderer.invoke('store:write', data), pick: (type) => ipcRenderer.invoke('dialog:pick', type), pickAvatar: () => ipcRenderer.invoke('dialog:avatar'), launch: (item) => ipcRenderer.invoke('item:launch', item), reveal: (target) => ipcRenderer.invoke('shell:reveal', target), toggleFullscreen: () => ipcRenderer.invoke('window:toggle-fullscreen') });

