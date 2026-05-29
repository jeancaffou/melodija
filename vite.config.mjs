import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { quasar, transformAssetUrls } from '@quasar/vite-plugin';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

function melodijaApiPlugin() {
  return {
    name: 'melodija-api',
    configureServer(server) {
      const { handleApiRequest } = require('./app/server/api.cjs');
      server.middlewares.use(async (req, res, next) => {
        if (req.url?.startsWith('/api')) {
          await handleApiRequest(req, res);
          return;
        }
        next();
      });
    }
  };
}

function melodijaDevFreshnessPlugin() {
  return {
    name: 'melodija-dev-freshness',
    apply: 'serve',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        if (!req.url?.startsWith('/api')) {
          res.setHeader('Cache-Control', 'no-store, max-age=0, must-revalidate');
          res.setHeader('Pragma', 'no-cache');
          res.setHeader('Expires', '0');
        }
        next();
      });

      server.watcher.on('change', (file) => {
        if (!file.includes('/app/renderer/')) return;
        const modules = server.moduleGraph.getModulesByFile(file);
        if (!modules) return;
        for (const mod of modules) {
          server.moduleGraph.invalidateModule(mod);
        }
      });
    }
  };
}

export default defineConfig({
  root: 'app/renderer',
  base: './',
  plugins: [
    melodijaDevFreshnessPlugin(),
    melodijaApiPlugin(),
    vue({
      template: { transformAssetUrls }
    }),
    quasar({
      sassVariables: false
    })
  ],
  server: {
    host: '0.0.0.0',
    port: 3333,
    strictPort: true,
    hmr: {
      host: 'localhost',
      port: 3333,
      protocol: 'ws'
    },
    watch: {
      usePolling: true,
      interval: 100
    }
  },
  build: {
    outDir: '../../dist/renderer',
    emptyOutDir: true
  }
});
