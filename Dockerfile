FROM node:20-bookworm-slim AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY app ./app
COPY vite.config.mjs ./
RUN npm run build:renderer:docker

FROM node:20-bookworm-slim AS runtime

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3333 \
    MELODIJA_DB=/data/melodija.db \
    MELODIJA_BACKUP_DIR=/data/backups \
    MELODIJA_STATIC_ROOT=/app/dist/renderer

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build /app/dist ./dist
COPY app/server ./app/server

RUN mkdir -p /data/backups

EXPOSE 3333

CMD ["node", "app/server/spa-server.cjs"]
