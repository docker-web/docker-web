FROM docker:dind
WORKDIR /home
VOLUME ./src/ /home/docker-web/src/services

RUN apk add bash git curl
RUN git clone --depth 1 https://github.com/docker-web/docker-web.git
