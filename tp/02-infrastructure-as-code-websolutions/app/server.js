const http = require('node:http');

function createServer({ checkDatabase = async () => {}, version = 'local' } = {}) {
  return http.createServer(async (request, response) => {
    if (request.method === 'GET' && request.url === '/health') {
      try {
        await checkDatabase();
        response.writeHead(200, { 'Content-Type': 'application/json' });
        response.end(JSON.stringify({ status: 'ok', database: 'ok', version }));
      } catch {
        response.writeHead(503, { 'Content-Type': 'application/json' });
        response.end(JSON.stringify({ status: 'error', database: 'unavailable', version }));
      }
      return;
    }

    if (request.method === 'GET' && request.url === '/') {
      response.writeHead(200, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify({ service: 'WebSolutions API', version }));
      return;
    }

    response.writeHead(404, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({ error: 'not found' }));
  });
}

if (require.main === module) {
  const { Pool } = require('pg');
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const port = Number(process.env.PORT || 3000);
  const server = createServer({
    checkDatabase: () => pool.query('SELECT 1'),
    version: process.env.APP_VERSION || 'local'
  });

  server.listen(port, '0.0.0.0', () => {
    console.log(`WebSolutions API ${process.env.APP_VERSION || 'local'} listening on ${port}`);
  });

  for (const signal of ['SIGINT', 'SIGTERM']) {
    process.on(signal, () => {
      server.close(() => pool.end().then(() => process.exit(0)));
    });
  }
}

module.exports = createServer;