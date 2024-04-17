FROM docker:dind

WORKDIR /root

RUN apk add bash git curl

RUN rm -rf /tmp/docker-web
RUN git clone --depth 1 https://github.com/docker-web/docker-web.git /tmp/docker-web
RUN mv /tmp/docker-web/src /tmp/docker-web/template /root
RUN if [ ! -d /root/services ]; then mv /tmp/docker-web/services /root; fi
