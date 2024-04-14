#!/bin/bash
TEST_CMD() {
  if ! command -v $1 1>/dev/null
  then
    echo "install $1 first"
  fi
}

INSTALL_ALIASES() {
  echo "[*] install aliases"
  if [ -e "~/.bashrc" ] && ! grep -q "alias.sh" "~/.bashrc"; then
    echo "source $PATH_DOCKERWEB/alias.sh"  | tee -a ~/.bashrc
  elif [ -e "~/.bash_profile" ] && ! grep -q "alias.sh" "~/.bash_profile"; then
    echo "source $PATH_DOCKERWEB/alias.sh"  | tee -a ~/.bash_profile
  fi
  echo "[*] init"
  source <(curl -s $PATH_DOCKERWEB/alias.sh)
}

TEST_CMD "curl"
TEST_CMD "docker"
INSTALL_ALIASES
echo "[√] docker-web successfully installed"
