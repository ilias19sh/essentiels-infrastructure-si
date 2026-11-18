FROM node:24-alpine

ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /app
COPY --chown=node:node server.js ./server.js

USER node
EXPOSE 3000
CMD ["node", "server.js"]
