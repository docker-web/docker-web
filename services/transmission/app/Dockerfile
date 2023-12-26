ARG NODE_VERSION=node:16.14.2-alpine
# 1 - INSTALL
FROM $NODE_VERSION AS install

RUN mkdir -p /app
WORKDIR /app

COPY package.json .
COPY package-lock.json .
COPY .env .
RUN npm ci

# 2 - CONFIGURE
FROM install AS configure

COPY . .
COPY .env .

# avoid conflict with nuxt build:
RUN sed -i "s|PORT=.*||g" .env

RUN npm run generate
RUN npm run build

# 3 - PRODUCTION
FROM $NODE_VERSION AS production

ENV WEB_DIR /var/www/
RUN mkdir -p $WEB_DIR
WORKDIR $WEB_DIR
COPY .env $WEB_DIR
COPY ./ $WEB_DIR

RUN apk add --no-cache ffmpeg curl nodejs python3 &&\
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp &&\
    chmod a+rx /usr/local/bin/yt-dlp
RUN yarn
RUN yt-dlp -U

# RUN adduser -S www-data -u 1000

# USER www-data

WORKDIR /app

COPY --from=install /app/node_modules /app/node_modules
COPY --from=configure /app /app
COPY --from=configure /app/.output /app/.output
COPY --from=configure /app/.env /app/

RUN cp /app/.env /app/.output/server/

ENV NUXT_HOST=0.0.0.0
ARG NUXT_APP_VERSION
ENV NUXT_APP_VERSION=${NUXT_APP_VERSION}
ENV NODE_ENV=production

CMD source .env && node .output/server/index.mjs
