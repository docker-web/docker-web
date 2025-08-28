UPGRADE() {
  echo "[i] upgrade keep config.sh and custom apps"

  OLD_DOCKERWEB_VERSION=$DOCKERWEB_VERSION

  rm -rf /tmp/docker-web
  git clone --depth 1 $URL_DOCKERWEB_GITHUB /tmp/docker-web

  rm -rf $PATH_DOCKERWEB/src
  mv /tmp/docker-web/src $PATH_DOCKERWEB

  source $PATH_DOCKERWEB/src/env.sh
  echo "[√] docker-web is now upgraded (v$OLD_DOCKERWEB_VERSION -> v$DOCKERWEB_VERSION)"
}
