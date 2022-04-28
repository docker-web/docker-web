#!/bin/sh
# v0.1

message() {
  CS='\033[1;34;40m'  # color start
  CE='\033[0m'        # color end

  echo "$CS $1 $CE"
}

PEGAZ_PATH="/etc/pegaz"
COMMANDS="build config create down events exec help images kill logs pause port ps pull push restart rm run scale start stop top unpause up version"
SERVICES=$(find $PEGAZ_PATH -maxdepth 1 -not -name '.*' -type d -printf '%f\n')

TEST_ROOT() {
  if ! echo $(whoami) | grep -q root
  then
    message "you need to be root"
    exit
  fi
}

CONFIG() {
  message "domain (ex: mydomain.com):"
  read DOMAIN
  message "username:"
  read USER
  message "password:"
  read PASS
  sed -i s/domain_default/$DOMAIN/g $PEGAZ_PATH/env.sh
  sed -i s/user_default/$USER/g $PEGAZ_PATH/env.sh
  sed -i s/pass_default/$PASS/g $PEGAZ_PATH/env.sh
  sed -i s/user@domain_default/$USER@$DOMAIN/g $PEGAZ_PATH/env.sh
}

TEST_ROOT

if ! test $1
then
  ls -d $PEGAZ_PATH
elif test $1 = "config"
then
  CONFIG
elif test $2
then
  if test $SERVICES =~ $2
  then
    if test $1 = "install"
    then
      (cd $PEGAZ_PATH/$2; source ../env.sh && source config.sh && docker-compose up -d;)
    elif test $1 = "update"
    then
      (cd $PEGAZ_PATH/$2; source ../env.sh && source config.sh && docker-compose pull;)
    elif ! test echo $COMMANDS | grep -q $1
    then
      (cd $PEGAZ_PATH/$2; source ../env.sh && source config.sh && docker-compose $1;)
    else
      message "command $1 not found"
    fi
  else
    message "pegaz can\'t $1 $2, choose a service above :"
    ls -d $PEGAZ_PATH
  fi
else
  message "you need to precise witch service you want to $1: "
  ls -d $PEGAZ_PATH
fi
