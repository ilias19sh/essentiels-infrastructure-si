const http = require('node:http');
const { Pool } = require('pg');
const { createClient } = require('redis');

const db = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  connectionTimeoutMillis: 2000,
  query_timeout: 2000
});
db.on('error', (error) => console.error(error.message));

const cache = createClient({
  url: process.env.REDIS_URL,
  disableOfflineQueue: true,
  socket: { connectTimeout: 2000 }
});
cache.on('error', (error) => console.error(error.message));

function json(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

async function route(req, res) {
  try {
    if (req.method === 'GET' && req.url === '/health') {
      await Promise.all([db.query('SELECT 1'), cache.ping()]);
      return json(res, 200, { database: 'ok', redis: 'ok' });
    }

    if (req.method === 'GET' && req.url === '/products') {
      const saved = await cache.get('products:v1');
      if (saved) {
        return json(res, 200, { source: 'redis', products: JSON.parse(saved) });
      }

      const result = await db.query('SELECT id, name FROM products ORDER BY id');
      await cache.set('products:v1', JSON.stringify(result.rows), { EX: 30 });
      return json(res, 200, { source: 'postgresql', products: result.rows });
    }

    return json(res, 404, { error: 'route introuvable' });
  } catch (error) {
    console.error(error.message);
    return json(res, 503, { error: 'dependance indisponible' });
  }
}

async function start() {
  await db.query(
    'CREATE TABLE IF NOT EXISTS products (id integer PRIMARY KEY, name text)'
  );
  await db.query(
    'INSERT INTO products VALUES ($1, $2), ($3, $4) ON CONFLICT DO NOTHING',
    [1, 'Clavier', 2, 'Souris']
  );
  await cache.connect();
  http.createServer(route).listen(3000, '0.0.0.0');
}

start().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
