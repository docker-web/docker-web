#!/bin/bash
TEST_CMD() {
  [[ ! -n $(command -v $1) ]] && echo "install $1 first"
}

CLONE_PROJECT() {
  cd ~
  git clone --depth 1 https://github.com/docker-web/docker-web
}

INSTALL_ALIASES() {
  echo "[*] install aliases"
  source ~/docker-web/src/env.sh
  [[ -f ~/.bashrc ]] && BASHFILE=".bashrc"
  [[ -f ~/.bash_profile ]] && BASHFILE=".bash_profile"
  sed -i "s|BASHFILE=.*|BASHFILE=$BASHFILE|g" $PATH_DOCKERWEB/src/config.sh
  [[ ! $(grep -q alias.sh ~/$BASHFILE; echo $?) -eq 0 ]] && echo "source $PATH_DOCKERWEB/alias.sh" | tee -a ~/$BASHFILE >/dev/null
  [[ ! $(grep -q completion.sh ~/$BASHFILE; echo $?) -eq 0 ]] && echo "source $PATH_DOCKERWEB/completion.sh" | tee -a ~/$BASHFILE >/dev/null
  source ~/$BASHFILE
  echo "[*] init"
}

TEST_CMD "curl"
TEST_CMD "git"
TEST_CMD "docker"
CLONE_PROJECT
INSTALL_ALIASES
echo "[√] docker-web successfully installed"
