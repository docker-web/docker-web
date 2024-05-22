POST_INSTALL() {
  local POST_INSTALL_TEST_CMD=""
  SOURCE_APP $1
  local PATH_SCRIPT="$PATH_DOCKERWEB_APPS/$1/$FILENAME_POST_INSTALL"
  if [[ -f $PATH_SCRIPT ]]
  then
    echo "[*] post-install: wait for $1 up"
    if [[ -n $POST_INSTALL_TEST_CMD ]]
    then
      while :
      do
        $POST_INSTALL_TEST_CMD >> /dev/null
        if [[ $? -eq 0 ]]
        then
          echo "[*] $POST_INSTALL_TEST_CMD is enable, launch post-install.sh"
          bash $PATH_SCRIPT $1
          break
        else
          continue
        fi
      done
    else
      while :
      do
        HTTP_CODE=$(curl -ILs $DOMAIN | head -n 1 | cut -d$' ' -f2)
        if [[ $HTTP_CODE < "400" ]]
        then
          echo "[*] $DOMAIN http status code is $HTTP_CODE, launch post-install.sh"
          bash $PATH_SCRIPT $1 &&\
          break
        else
          continue
        fi
      done
    fi
  fi
}
