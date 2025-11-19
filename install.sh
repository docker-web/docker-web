#!/bin/bash

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
  git clone --depth 1 https://github.com/docker-web/docker-web
  chown -R $SUDO_USER:$SUDO_USER /var/docker-web
}

INSTALL_HOOK() {
  cp /var/docker-web/pre-commit /var/docker-web/.git/hooks/pre-commit
}

INSTALL_ALIASES() {
  source /var/docker-web/src/env.sh
  [[ -f ~/.bashrc ]] && BASHFILE=".bashrc"
  [[ -f ~/.bash_profile ]] && BASHFILE=".bash_profile"
  sed -i "s|BASHFILE=.*|BASHFILE=$BASHFILE|g" /var/docker-web/config.sh
  grep -q alias.sh ~/$BASHFILE || echo "source /var/docker-web/src/alias.sh" >> ~/$BASHFILE
  grep -q completion.sh ~/$BASHFILE || echo "source /var/docker-web/src/completion.sh" >> ~/$BASHFILE
  source ~/$BASHFILE
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
