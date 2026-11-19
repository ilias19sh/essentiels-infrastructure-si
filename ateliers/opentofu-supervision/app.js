const http = require('node:http');
const fs = require('node:fs');

const journal = '/logs/http.log';
let requests = 0;

fs.appendFileSync(journal, '', { mode: 0o644 });

http.createServer((req, res) => {
  if (req.url === '/metrics') {
    res.writeHead(200, { 'Content-Type': 'text/plain; version=0.0.4' });
    return res.end('# TYPE http_requests_total counter\n'
      + 'http_requests_total ' + requests + '\n');
  }

  requests++;
  const status = req.url === '/' ? 200 : 404;
  fs.appendFileSync(journal, JSON.stringify({
    time: new Date().toISOString(), path: req.url, status,
  }) + '\n');
  res.writeHead(status, { 'Content-Type': 'text/plain; charset=utf-8' });
  res.end(status === 200 ? 'Application Node.js supervisée' : 'Introuvable');
}).listen(8080, '0.0.0.0');