const http = require('node:http');

const server = http.createServer((_request, response) => {
  response.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
  response.end('Hello, Docker and Minikube from Node.js!');
});

server.listen(3000, '0.0.0.0');
