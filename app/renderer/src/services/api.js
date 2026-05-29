const apiBase = window.melodija?.apiBase || '';

async function request(path, options = {}) {
  const response = await fetch(`${apiBase}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {})
    },
    ...options
  });
  const contentType = response.headers.get('content-type') || '';
  const payload = contentType.includes('application/json') ? await response.json() : await response.text();
  if (!response.ok) {
    throw new Error(payload?.error || payload || `HTTP ${response.status}`);
  }
  return payload;
}

export const api = {
  bootstrap: () => request('/api/bootstrap'),
  songs: (params) => request(`/api/songs?${new URLSearchParams(params)}`),
  song: (ownkey) => request(`/api/songs/${ownkey}`),
  nextSongNumber: (choir) => request(`/api/songs/next-number?${new URLSearchParams({ choir })}`),
  saveSong: (song) => {
    const ownkey = song.ownkey || 0;
    return request(ownkey ? `/api/songs/${ownkey}` : '/api/songs', {
      method: ownkey ? 'PUT' : 'POST',
      body: JSON.stringify(song)
    });
  },
  deleteSong: (ownkey) => request(`/api/songs/${ownkey}`, { method: 'DELETE' }),
  notes: (params = {}) => request(`/api/notes?${new URLSearchParams(params)}`),
  authors: (params = {}) => request(`/api/authors?${new URLSearchParams(params)}`),
  quickSearch: (params = {}) => request(`/api/search?${new URLSearchParams(params)}`),
  nextAuthorId: () => request('/api/authors/next-id'),
  saveAuthor: (author) => request(author.id ? `/api/authors/${author.id}` : '/api/authors', {
    method: author.id ? 'PUT' : 'POST',
    body: JSON.stringify(author)
  }),
  deleteAuthor: (id) => request(`/api/authors/${id}`, { method: 'DELETE' }),
  choirs: (params = {}) => request(`/api/choirs?${new URLSearchParams(params)}`),
  nextChoirId: () => request('/api/choirs/next-id'),
  saveChoir: (choir) => request(choir.id ? `/api/choirs/${choir.id}` : '/api/choirs', {
    method: choir.id ? 'PUT' : 'POST',
    body: JSON.stringify(choir)
  }),
  deleteChoir: (id) => request(`/api/choirs/${id}`, { method: 'DELETE' }),
  report: (params) => {
    const type = params.type;
    const query = new URLSearchParams({ ...params });
    query.delete('type');
    return request(`/api/reports/${type}?${query}`);
  },
  setSetting: (key, value) => request('/api/settings', {
    method: 'POST',
    body: JSON.stringify({ key, value })
  }),
  maintenance: () => request('/api/maintenance'),
  backupDatabase: () => request('/api/maintenance/backup', { method: 'POST' }),
  restoreDatabase: () => request('/api/maintenance/restore', { method: 'POST' }),
  rebuildDatabase: () => request('/api/maintenance/rebuild', { method: 'POST' }),
  setAppClock: (date, time) => request('/api/maintenance/app-clock', {
    method: 'POST',
    body: JSON.stringify({ date, time })
  }),
  setOperator: (operator) => request('/api/maintenance/operator', {
    method: 'POST',
    body: JSON.stringify({ operator })
  }),
  corrections: (params = {}) => request(`/api/corrections?${new URLSearchParams(params)}`),
  databaseTables: () => request('/api/database/tables'),
  databaseRows: (table, params = {}) => request(`/api/database/${table}?${new URLSearchParams(params)}`)
};
