POST_INSTALL() {
  local POST_INSTALL_TEST_CMD=""
  SOURCE_APP $1
  local PATH_SCRIPT="$PATH_APPS/$1/$FILENAME_POSTINSTALL"
  if [[ -f $PATH_SCRIPT ]]
  then
    echo "[*] post-install: wait for $1 up"
    local RETRY_COUNT=0
    local MAX_RETRIES=60
    if [[ -n $POST_INSTALL_TEST_CMD ]]
    then
      while [ $RETRY_COUNT -lt $MAX_RETRIES ]
      do
        $POST_INSTALL_TEST_CMD >> /dev/null
        if [[ $? -eq 0 ]]
        then
          echo "[*] $POST_INSTALL_TEST_CMD is enable, launch post-install.sh"
          bash "$PATH_SCRIPT" "$1"
          break
        else
          sleep 1
          RETRY_COUNT=$((RETRY_COUNT + 1))
        fi
      done
    else
      while [ $RETRY_COUNT -lt $MAX_RETRIES ]
      do
        HTTP_CODE=$(curl -ILs "$DOMAIN" 2>/dev/null | head -n 1 | cut -d' ' -f2)
        if [[ $HTTP_CODE =~ ^[23][0-9]{2}$ ]]
        then
          echo "[*] $DOMAIN http status code is $HTTP_CODE, launch post-install.sh"
          bash "$PATH_SCRIPT" "$1"
          break
        else
          sleep 1
          RETRY_COUNT=$((RETRY_COUNT + 1))
        fi
      done
      if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        echo "[!] post-install timeout after $MAX_RETRIES attempts for $1"
      fi
    fi
  fi
}
