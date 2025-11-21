UPGRADE() {
  local OLD_VERSION TMP_FOLDER

  OLD_VERSION=$DOCKERWEB_VERSION
  TMP_FOLDER=/tmp/docker-web

  rm -rf $TMP_FOLDER
  mkdir $TMP_FOLDER

  git clone --depth 1 $URL_GITHUB $TMP_FOLDER

  # protect user configurations
  rm $TMP_FOLDER/config.sh

  cp -a $TMP_FOLDER/* "$PATH_DOCKERWEB/"

  source $PATH_DOCKERWEB/src/env.sh
  echo "[√] docker-web is now upgraded (v$OLD_VERSION -> v$DOCKERWEB_VERSION)"
}
