FROM nextcloud:apache

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
  libffi-dev \
  imagemagick;

RUN \
docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
docker-php-ext-install \
  bz2 \
  ffi \
  imap;

RUN mkdir -p \
  /var/log/supervisord \
  /var/run/supervisord;

COPY nextcloud.conf /

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord", "-c", "/nextcloud.conf"]
