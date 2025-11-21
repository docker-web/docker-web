#!/bin/bash
PATH_DOCKERWEB=/var/docker-web

TEST_SUDO() {
  if [ "$EUID" -ne 0 ]; then
    echo "[x] This script must be run with sudo privileges"
    exit 1
  fi
}

TEST_CMD() {
  if "$@" --help >/dev/null 2>&1; then
    echo "[√] $* ok"
  else
    echo "[x] $* missing"
    exit 1
  fi
}

CLONE_PROJECT() {
  cd /var || exit 1
  git clone --depth 1 $URL_GITHUB
  chown -R $SUDO_USER:$SUDO_USER $PATH_DOCKERWEB
}

INSTALL_HOOK() {
  cp $PATH_DOCKERWEB/pre-commit $PATH_DOCKERWEB/.git/hooks/pre-commit
}

INSTALL_ALIASES() {
  source $PATH_DOCKERWEB/src/env.sh
  [[ -f ~/.bashrc ]] && PATH_BASHFILE=".bashrc"
  [[ -f ~/.bash_profile ]] && PATH_BASHFILE=".bash_profile"
  sed -i "s|PATH_BASHFILE=.*|PATH_BASHFILE=$PATH_BASHFILE|g" $PATH_DOCKERWEB/src/env.sh
  grep -q alias.sh $PATH_BASHFILE || echo "source $PATH_DOCKERWEB/src/alias.sh" >> $PATH_BASHFILE
  grep -q completion.sh $PATH_BASHFILE || echo "source $PATH_DOCKERWEB/src/completion.sh" >> $PATH_BASHFILE
  source $PATH_BASHFILE
}

TEST_SUDO
TEST_CMD curl
TEST_CMD git
TEST_CMD docker
TEST_CMD docker compose
TEST_CMD git archive

CLONE_PROJECT
INSTALL_HOOK
INSTALL_ALIASES
echo "[√] docker-web successfully installed"
