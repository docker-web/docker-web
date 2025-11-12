FROM nextcloud:apache

# Installer uniquement ce qui est dispo
RUN apt-get update && apt-get install -y --no-install-recommends \
      ffmpeg \
      procps \
      smbclient \
      supervisor \
      sudo \
      nano \
      libbz2-dev \
      libfuse2 \
      libkrb5-dev \
      libsmbclient-dev \
      libffi-dev \
      imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Extensions PHP utiles
RUN docker-php-ext-install bz2 ffi

# Supervisord
RUN mkdir -p /var/log/supervisord /var/run/supervisord
COPY nextcloud.conf /

ENV NEXTCLOUD_UPDATE=1
CMD ["/usr/bin/supervisord", "-c", "/nextcloud.conf"]
