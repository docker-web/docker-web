#!/bin/sh

COMMANDS="build config create down events exec help images kill logs pause port ps pull push restart rm run scale start stop top unpause up version"
PEGAZ_PATH=/etc/pegaz

CONFIG() {
  echo -n "Pegaz need some infos to init your setup"
  echo -n "domain (ex: mydomain.com):"
  read $DOMAIN
  echo -n "username:"
  read $USER
  echo -n "password:"
  read $PASS
  sed "s/domain_default/$domain;s/user_default/$user;s/pass_default/$pass;s/user@domain_default/$user@$domain $PEGAZ_PATH/env.sh"
}

if ! test $1 || test $1 = "config"
then
  CONFIG
elif test $2
then
  if test ls -d $PEGAZ_PATH grep -q $2
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
      echo "command $1 not found"
    fi
  else
    echo "pegaz can\'t $1 $2, choose a service above :"
    echo ls -d $PEGAZ_PATH
  fi
else
  echo "you need to precise witch service you want to $1: "
  echo ls -d $PEGAZ_PATH
fi
