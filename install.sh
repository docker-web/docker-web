#!/bin/bash
source src/env.sh
TEST_CMD() {
  if ! command -v $1 1>/dev/null
  then
    echo "install $1 first"
  fi
}

CLONE_PROJECT() {
  cd ~
  git clone --depth 1  GITHUB_DOCKERWEB
}

INSTALL_ALIASES() {
  echo "[*] install aliases"
  if [ -f ~/.bashrc ] && ! grep -q alias.sh ~/.bashrc; then
    BASHFILE=".bashrc"
  elif [ -f ~/.bash_profile ] && ! grep -q alias.sh ~/.bash_profile; then
   BASHFILE=".bash_profile"
  else
    BASHFILE="bash_profile"
  fi
  sed -i "s|BASHFILE=.*|BASHFILE=$BASHFILE|g" $PATH_DOCKERWEB/src/config.sh 
  echo "source $PATH_DOCKERWEB/alias.sh" | tee -a ~/$BASHFILE >/dev/null
  echo "source $PATH_DOCKERWEB/completion.sh" | tee -a ~/$BASHFILE >/dev/null
  source ~/$BASHFILE
  echo "[*] init"
}

TEST_CMD "curl"
TEST_CMD "git"
TEST_CMD "docker"
CLONE_PROJECT
INSTALL_ALIASES
echo "[√] docker-web successfully installed"
