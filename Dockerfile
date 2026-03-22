FROM node:22-slim AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --ignore-scripts

COPY . .

RUN npm run build

# try doing this and see if it works
RUN npm prune --omit-dev

# RUN npm prune --omit=dev

FROM node:22-slim AS runner

WORKDIR /app

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/dist ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/wait-for-it.sh /usr/local/bin/wait-for-it.sh

RUN chmod +x /usr/local/bin/wait-for-it.sh

EXPOSE 3001

RUN useradd -m appuser
USER appuser

ENTRYPOINT ["wait-for-it.sh", "blog-db:3306", "--"]
CMD ["node", "index.js"]
