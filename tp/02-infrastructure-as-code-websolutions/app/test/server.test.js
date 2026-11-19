const assert = require('node:assert/strict');
const { once } = require('node:events');
const test = require('node:test');
const createServer = require('../server');

async function startTestServer(t, options) {
  const server = createServer(options);
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  t.after(() => {
    server.closeAllConnections();
    return new Promise((resolve, reject) => {
      server.close((error) => error ? reject(error) : resolve());
    });
  });
  return `http://127.0.0.1:${server.address().port}`;
}

test('GET /health reports the database and application version', async (t) => {
  const url = await startTestServer(t, {
    checkDatabase: async () => {},
    version: 'test-123'
  });
  const response = await fetch(`${url}/health`);

  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    status: 'ok',
    database: 'ok',
    version: 'test-123'
  });
});

test('GET /health returns 503 when PostgreSQL is unavailable', async (t) => {
  const url = await startTestServer(t, {
    checkDatabase: async () => { throw new Error('database unavailable'); },
    version: 'test-123'
  });
  const response = await fetch(`${url}/health`);

  assert.equal(response.status, 503);
  assert.deepEqual(await response.json(), {
    status: 'error',
    database: 'unavailable',
    version: 'test-123'
  });
});

test('GET / identifies the service and deployed version', async (t) => {
  const url = await startTestServer(t, { version: 'release-42' });
  const response = await fetch(url);

  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    service: 'WebSolutions API',
    version: 'release-42'
  });
});