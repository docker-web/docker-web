DROP() {
  local LOCAL_PATH=$(pwd)
  echo "[?] Are you sure to drop $1 (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    EXECUTE "down" $1
    $IS_DOCKERWEBDEV && cd $LOCAL_PATH
    rm -rf "$PATH_DOCKERWEB/services/$1" "$PATH_DOCKERWEB_SERVICES/$1"
  fi
}
