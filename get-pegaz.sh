#!/bin/sh

PEGAZ_GITHUB=https://github.com/valerebron/pegaz
PEGAZ_PATH=/etc/pegaz

INSTALL_GIT() {
  if ! [command -v git &> /dev/null]; then
    if [command -v apt &> /dev/null]; then
      apt update -y && apt install -y git
    elif [command -v apk &> /dev/null]; then
      apk update && apk add git
    else
      echo "install git first: https://github.com/git-guides/install-git"
      return 3
    fi
  else
    return 0
  fi
}
INSTALL_DOCKER() {
  if ! [command -v docker &> /dev/null]; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
    rm get-docker.sh
  fi
}

INSTALL_GIT
INSTALL_DOCKER
if ! [ docker network ls | grep pegaz ]; then
  docker network create pegaz
fi
if ! [ EXIST $PEGAZ_PATH/pegaz.sh ]; then
  git clone $PEGAZ_GITHUB $PEGAZ_PATH
  chmod +x $PEGAZ_PATH/pegaz.sh
fi
if ! [ grep -q pegaz etc/bash.bashrc ]; then
  echo "alias pegaz='sh $PEGAZ_PATH/pegaz.sh $1 $2'" >> /etc/bash.bashrc
fi

pegaz
