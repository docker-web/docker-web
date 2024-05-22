TEST_CONFIG() {
  if [[ -z $MAIN_DOMAIN || -z $USERNAME || -z $PASSWORD || $TESTIMONIAL == true ]]
  then
    echo "[!] config docker-web first"
    CONFIG
    sed -i 's/TESTIMONIAL=true/TESTIMONIAL=false/' $PATH_DOCKERWEB/$FILENAME_CONFIG
  fi
}
