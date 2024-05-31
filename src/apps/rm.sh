RM() {
  local LOCAL_PATH=$(pwd)
  echo "[?] Are you sure to drop $1 (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    EXECUTE "down -v" $1
    rm -rf $PATH_DOCKERWEB_APPS/$1
  fi
}
