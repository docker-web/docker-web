FROM nextcloud:24.0.1-apache

RUN \
apt-get update; \
apt-get install -y --no-install-recommends \
  ffmpeg \
  libmagickcore-6.q16-6-extra \
  procps \
  smbclient \
  supervisor \
  sudo \
  nano \
  libbz2-dev \
  libc-client-dev \
  libkrb5-dev \
  libsmbclient-dev \
  imagemagick;

RUN \
docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
docker-php-ext-install \
  bz2 \
  imap;

RUN mkdir -p \
  /var/log/supervisord \
  /var/run/supervisord;

ENV NEXTCLOUD_UPDATE=1

COPY post-install.sh /
# RUN sed -i '/exec "$@"/e cat /post-install.sh' /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
