FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
WORKDIR /app
RUN corepack enable
# ATTENTION: Update version when update pnpm version
RUN corepack install -g pnpm@9.13.2

# Development dependencies
FROM base AS deps

COPY pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm fetch

COPY package.json ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile --offline

# Production dependencies
FROM deps AS deps_prod
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm prune --prod

# Build the application
FROM deps AS build
COPY src ./src
COPY public ./public
COPY vite.config.ts ./
COPY tsconfig*.json ./
COPY index.html ./
COPY .env* ./
# Build the application
RUN pnpm build

FROM caddy:2
WORKDIR /var/www
COPY --from=build /app/.env.production /var/www/
COPY --from=build /app/dist /var/www

COPY Caddyfile /etc/caddy/Caddyfile

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
