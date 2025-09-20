#!/bin/bash

# Vérifie si exécuté avec sudo
TEST_SUDO() {
  if [ "$EUID" -ne 0 ]; then
    echo "[x] This script must be run with sudo privileges"
    exit 1
  fi
}

# Vérifie qu'une commande ou sous-commande existe
TEST_AVAILABLE() {
  if "$@" --help >/dev/null 2>&1; then
    echo "[√] $* ok"
  else
    echo "[x] $* missing"
    exit 1
  fi
}

# Clone projet
CLONE_PROJECT() {
  cd /var || exit 1
  git clone --depth 1 https://github.com/docker-web/docker-web
  chown -R $SUDO_USER:$SUDO_USER /var/docker-web
}

# Install git hook
INSTALL_HOOK() {
  cp /var/docker-web/pre-commit /var/docker-web/.git/hooks/pre-commit
}

# Install alias
INSTALL_ALIASES() {
  source /var/docker-web/src/env.sh
  [[ -f ~/.bashrc ]] && BASHFILE=".bashrc"
  [[ -f ~/.bash_profile ]] && BASHFILE=".bash_profile"
  sed -i "s|BASHFILE=.*|BASHFILE=$BASHFILE|g" /var/docker-web/config.sh
  grep -q alias.sh ~/$BASHFILE || echo "source /var/docker-web/src/alias.sh" >> ~/$BASHFILE
  grep -q completion.sh ~/$BASHFILE || echo "source /var/docker-web/src/completion.sh" >> ~/$BASHFILE
  source ~/$BASHFILE
}

# checks
TEST_SUDO
TEST_AVAILABLE curl
TEST_AVAILABLE git
TEST_AVAILABLE docker
TEST_AVAILABLE docker compose
TEST_AVAILABLE git archive

# install steps
CLONE_PROJECT
INSTALL_HOOK
INSTALL_ALIASES
echo "[√] docker-web successfully installed"
