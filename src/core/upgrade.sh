UPGRADE() {
  local OLD_VERSION NEW_VERSION TMP_FOLDER URL_DOCKERWEB_GITHUB PATH_DOCKERWEB
 
  OLD_VERSION=$NEW_VERSION
  TMP_FOLDER=/tmp/docker-web
  
  rm -rf $TMP_FOLDER

  git clone --depth 1 $URL_DOCKERWEB_GITHUB $TMP_FOLDER

  rm $TMP_FOLDER/config.sh

  cp -a $TMP_FOLDER/* "$PATH_DOCKERWEB/"

  echo "[√] docker-web is now upgraded (v$OLD_VERSION -> v$NEW_VERSION)"
}
