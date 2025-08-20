RM() {
  echo $2
  if [ "$2" = "-y" ]
  then
    ANSWER="y"
  else
    echo "[?] Are you sure to drop $1 (Y/n)"
    read ANSWER
  fi
  if [[ $ANSWER == "Y" || $ANSWER == "y" || $ANSWER == "" ]]
  then
    if docker ps -f "name=$1" -f "status=running" --format "{{.Names}}" | grep -q "^$1$"
    then
      EXECUTE "down -v" $1
    fi
    if [ "$(basename "$WORK_DIR")" = "docker-web" ]
    then
      RELATIVE_PATH_APPS="$WORK_DIR/apps/$1"
    fi

    if [ -d $RELATIVE_PATH_APPS ]
    then
      rm -rf $RELATIVE_PATH_APPS
    fi
    if [ -d $PATH_DOCKERWEB_APPS/$1 ]
    then
      rm -rf $PATH_DOCKERWEB_APPS/$1
    fi
  fi
}

