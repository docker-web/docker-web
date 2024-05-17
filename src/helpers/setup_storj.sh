SETUP_STORJ() {
  if ! command -v "uplink" 1>/dev/null
  then
    echo "[*] install uplink"
    case $(arch) in
      x86_64)
        curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink.zip
        ;;
      armv*)
        curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_arm.zip -o uplink.zip
        ;;
      aarch64)
        curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_arm64.zip -o uplink.zip
        ;;
    esac
    unzip -o uplink.zip
    sudo install uplink /usr/local/bin/uplink
    rm uplink.zip
    uplink setup
  fi
  if [[ -z $STORJ_BUCKET_NAME ]]
  then
    echo "[?] what's your storj bucket name ?"
    read STORJ_BUCKET_NAME
    [[ -n $STORJ_BUCKET_NAME ]] && sed -i "s|STORJ_BUCKET_NAME=.*|STORJ_BUCKET_NAME=\"$STORJ_BUCKET_NAME\"|g" $PATH_DOCKERWEB/src/config.sh
  fi
}
