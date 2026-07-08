TEST_CONFIG() {
  if [[ -z $MAIN_DOMAIN || $TESTIMONIAL == true ]]
  then
    echo "[!] config docker-web first"
    CONFIG
    sed -i 's/TESTIMONIAL=true/TESTIMONIAL=false/' $PATH_DOCKERWEB/config.sh
  fi
}
