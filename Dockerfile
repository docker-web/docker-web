FROM docker:dind
WORKDIR /home

RUN apk add bash
RUN mkdir template;
    wget https://raw.githubusercontent.com/docker-web/docker-web/master/docker-web.sh; \
    wget https://raw.githubusercontent.com/docker-web/docker-web/master/env.sh; \
    cd template; \
    wget https://raw.githubusercontent.com/docker-web/docker-web/master/template/README.md; \
    wget https://raw.githubusercontent.com/docker-web/docker-web/master/template/config.sh; \
    wget https://raw.githubusercontent.com/docker-web/docker-web/master/template/docker-compose.yml; \
    wget https://raw.githubusercontent.com/docker-web/docker-web/master/template/logo.svg; \
