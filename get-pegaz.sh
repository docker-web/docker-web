#!/bin/sh
# v0.1
# curl -fsSL https://raw.githubusercontent.com/valerebron/pegaz/master/get-pegaz.sh -o get-pegaz.sh && sh get-pegaz.sh

PEGAZ_GITHUB=https://github.com/valerebron/pegaz
PEGAZ_PATH=/etc/pegaz

INSTALL_GIT() {
  if ! type git 1>/dev/null
  then
    if type apt 1>/dev/null
    then
      echo "pegaz :: install GIT"
      apt update -y && apt upgrade -y && apt install -y git
    elif type apk 1>/dev/null
    then
      echo "pegaz :: install GIT"
      apk update && apk add git
    else
      echo "pegaz :: install git first: https://github.com/git-guides/install-git"
      return 3
    fi
  else
    echo "pegaz :: skip GIT"
    return 0
  fi
}
INSTALL_DOCKER() {
  if ! type docker 1>/dev/null
  then
    echo "pegaz :: install DOCKER"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
    rm get-docker.sh
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  else
    echo "pegaz :: skip DOCKER"
  fi
}
CREATE_NETWORK() {
  $networkExist=$(docker network ls | grep pegaz)
  if test -n $networkExist
  then
    echo "pegaz :: create NETWORK"
    docker network create pegaz
  fi
}
CLONE_PROJECT() {
  if ! test -e $PEGAZ_PATH/pegaz.sh
  then
    echo "pegaz :: clone PROJECT"
    git clone $PEGAZ_GITHUB $PEGAZ_PATH
    chmod +x $PEGAZ_PATH/pegaz.sh
  fi
}
CREATE_ALIAS() {
  if ! alias pegaz 1>/dev/null
  then
    echo "pegaz :: create ALIAS"
    echo "alias pegaz='sh $PEGAZ_PATH/pegaz.sh \$1 \$2'" >> /etc/bash.bashrc
  fi
}

INSTALL_GIT
INSTALL_DOCKER
CREATE_NETWORK
CLONE_PROJECT
CREATE_ALIAS

sh $PEGAZ_PATH/pegaz.sh
