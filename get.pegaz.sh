#!/bin/bash
# curl https://raw.githubusercontent.com/valerebron/pegaz/master/get.pegaz.sh | sudo bash

# su
# usermod -aG sudo username
# exit; exit;

if test -z "$BASH_VERSION"; then
  echo "Please run this script using bash, not sh or any other shell." >&2
  exit 1
fi

source <(curl -s https://raw.githubusercontent.com/valerebron/pegaz/master/env.sh)

TEST_ROOT() {
  [[ ${EUID} -ne 0 ]] && printf "[x] must be run as root. Try 'curl https://raw.githubusercontent.com/valerebron/pegaz/master/get.pegaz.sh | sudo bash'\n" && exit
}

UPGRADE() {
  echo "[*] upgrade package manager"
  command -v apt 1>/dev/null && apt update --allow-releaseinfo-change -y
  command -v apk 1>/dev/null && apk update
  command -v pacman 1>/dev/null && pacman -Syy
  command -v yum 1>/dev/null && yum -y update
}

INSTALL_PKG() {
  if ! command -v $1 1>/dev/null
  then
    echo "[*] install $1"
    command -v apt 1>/dev/null && apt -y install $1
    command -v apk 1>/dev/null && apk add $1
    command -v pacman 1>/dev/null && pacman -Sy --noconfirm $1
    command -v yum 1>/dev/null && yum -y install $1
  fi
}

INSTALL_DOCKER() {
  if ! command -v "docker" 1>/dev/null
  then
    echo "[*] installing Docker..."
    curl -fsSL https://get.docker.com -o get.docker.sh
    chmod +x get.docker.sh
    sh get.docker.sh
    rm get.docker.sh

    if [[ -n $SUDO_USER ]]; then
      usermod -aG docker $SUDO_USER

      echo "You must log out or restart to apply necessary Docker permissions changes."
      echo "Restart, then continue installing using this script."
    fi
  fi
}

INSTALL_DOCKER_COMPOSE() {
  if ! command -v "docker-compose" 1>/dev/null
  then
    echo "[*] installing Docker Compose..."

    curl -fsSL -o docker-compose https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-$(uname -m)

    ARCHITECTURE=amd64
    if [ "$(uname -m)" = "aarch64" ]; then
      ARCHITECTURE=arm64
    fi
    curl -fsSL -o docker-compose-switch https://github.com/docker/compose-switch/releases/download/v1.0.4/docker-compose-linux-${ARCHITECTURE}

    if [[ -n $SUDO_USER ]]; then
      sudo chmod a+x ./docker-compose
      sudo chmod a+x ./docker-compose-switch

      sudo mv ./docker-compose /usr/libexec/docker/cli-plugins/docker-compose
      sudo mv ./docker-compose-switch /usr/local/bin/docker-compose
    else
      chmod a+x ./docker-compose
      chmod a+x ./docker-compose-switch

      mv ./docker-compose /usr/libexec/docker/cli-plugins/docker-compose
      mv ./docker-compose-switch /usr/local/bin/docker-compose
    fi
  fi
}

CLONE_PROJECT() {
  rm -rf /tmp/pegaz
  git clone $GITHUB_PEGAZ /tmp/pegaz
  mkdir -p $PATH_PEGAZ $MEDIA_DIR
  mv -vn /tmp/pegaz/* $PATH_PEGAZ
  mv -vn /tmp/pegaz/.git $PATH_PEGAZ && rm -rf /tmp/pegaz
  chmod -R 750 $PATH_PEGAZ $MEDIA_DIR
  [[ -n $SUDO_USER ]] && chown -R $SUDO_USER:$SUDO_USER $PATH_PEGAZ
}

INSTALL_CLI() {
  echo "[*] install cli"
  echo "source $PATH_PEGAZ/start.pegaz.sh"  | sudo tee -a /etc/profile
  echo "[*] init cli"
  source $PATH_PEGAZ/start.pegaz.sh
}

TEST_ROOT
UPGRADE
INSTALL_PKG "curl"
INSTALL_DOCKER
INSTALL_DOCKER_COMPOSE
INSTALL_PKG "sed"
INSTALL_PKG "sudo"
INSTALL_PKG "git"
CLONE_PROJECT
INSTALL_CLI
echo "re-open a shell session to get autocomplete"
echo "[√] pegaz $PEGAZ_VERSION successfully installed"
