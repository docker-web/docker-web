UPGRADE() {
  local OLD_VERSION TMP_FOLDER URL_DOCKERWEB_GITHUB PATH_DOCKERWEB

  OLD_VERSION=$DOCKERWEB_VERSION
  TMP_FOLDER=/tmp/docker-web

  mkdir -p $TMP_FOLDER

  git clone --depth 1 $URL_DOCKERWEB_GITHUB $TMP_FOLDER

  # protect user configurations
  rm $TMP_FOLDER/config.sh

  cp -a $TMP_FOLDER/* "$PATH_DOCKERWEB/"

  echo "[√] docker-web is now upgraded (v$OLD_VERSION -> v$DOCKERWEB_VERSION)"
}
