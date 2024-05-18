TEST_CONFIG() {
  source $PATH_DOCKERWEB/config.sh
  [[ -z $MAIN_DOMAIN || -z $USERNAME || -z $PASSWORD ]] && echo "[!] config docker-web first" && CONFIG
  [[ $MAIN_DOMAIN == "domain.com" && $IS_DOCKERWEBDEV == "false" ]] && echo "[!] please configure docker-web first" && CONFIG
}
