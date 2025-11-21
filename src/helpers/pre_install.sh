PRE_INSTALL() {
  SOURCE_APP $1
  local PATH_SCRIPT="$PATH_APPS/$1/$FILENAME_PREINSTALL"
  if [[ -f $PATH_SCRIPT ]]
  then
    echo "[*] pre-install"
    bash $PATH_SCRIPT $1
  fi
}
