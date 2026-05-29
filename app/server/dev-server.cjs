const { createServer } = require('vite');
const { handleApiRequest } = require('./api.cjs');

async function main() {
  const vite = await createServer({
    configFile: 'vite.config.mjs',
    server: {
      host: '0.0.0.0',
      port: 3333,
      strictPort: true
    }
  });

  vite.middlewares.use(async (req, res, next) => {
    if (req.url && req.url.startsWith('/api')) {
      await handleApiRequest(req, res);
      return;
    }
    next();
  });

  await vite.listen();
  vite.printUrls();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
