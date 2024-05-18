UPGRADE() {
  echo "[i] upgrade keep config.sh and custom services"

  rm -rf /tmp/docker-web
  git clone --depth 1 $GITHUB_DOCKERWEB /tmp/docker-web

  rm -rf $PATH_DOCKERWEB/src $PATH_DOCKERWEB/template $PATH_DOCKERWEB/docs
  mv /tmp/docker-web/src $PATH_DOCKERWEB
  mv /tmp/docker-web/template $PATH_DOCKERWEB
  mv /tmp/docker-web/docs $PATH_DOCKERWEB

  rsync -raz --ignore-existing /tmp/docker-web/services/* $PATH_DOCKERWEB_SERVICES
  rsync -raz --exclude "$PATH_DOCKERWEB_SERVICES/dashboard/web/index.html" --exclude "*config.sh" /tmp/docker-web/services/* $PATH_DOCKERWEB_SERVICES

  source $PATH_DOCKERWEB/src/env.sh
  echo "[√] docker-web is now upgraded (v$DOCKERWEB_VERSION)"
}
