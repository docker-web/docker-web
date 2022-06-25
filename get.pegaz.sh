#!/bin/bash
# curl -sL get.pegaz.io | bash

source <(curl -s https://raw.githubusercontent.com/valerebron/pegaz/master/env.sh)

INSTALL_GIT() {
  if ! type git 1>/dev/null
  then
    if type apt 1>/dev/null
    then
      echo "install git"
      apt update -y && apt upgrade -y && apt install -y git
    elif type apk 1>/dev/null
    then
      echo "install git"
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
  if ! type docker 1>/dev/null
  then
    echo "install docker"
    curl -fsSL https://get.docker.com | bash
    usermod -aG docker $USER
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  fi
}

CLONE_PROJECT() {
  if ! test -d $PATH_PEGAZ
  then
    sudo mkdir -p $PATH_PEGAZ $DATA_DIR
    sudo git clone $GITHUB_PEGAZ $PATH_PEGAZ
    sudo chown -R $USER:$USER $PATH_PEGAZ
    sudo chmod -R 750 $PATH_PEGAZ
  fi
}

CREATE_ALIAS() {
  if ! echo $(cat $PATH_BASHRC) | grep -q cli.pegaz.sh
  then
    echo "create alias"
    echo "alias pegaz='bash $PATH_PEGAZ/cli.pegaz.sh \$1 \$2'" >> $PATH_BASHRC
    echo "alias pegazdev='pwd | grep -q pegaz && rm -rf $PATH_PEGAZ/* && cp -ra ./* $PATH_PEGAZ && bash cli.pegaz.sh \$1 \$2'" >> $PATH_BASHRC

    cp $PATH_PEGAZ/completion.sh $PATH_COMPLETION/pegaz.sh
    complete -F _pegaz_completions pegaz pegazdev

    source $PATH_BASHRC
    source $PATH_COMPLETION/pegaz.sh
  fi
}

CLONE_PROJECT
INSTALL_GIT
INSTALL_DOCKER
CREATE_ALIAS

bash $PATH_PEGAZ/cli.pegaz.sh -h
