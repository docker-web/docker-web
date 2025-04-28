UPDATE_LAUNCHER() {
  if [[ "$1" != "launcher" ]]; then
    local state
    state=$(GET_STATE "launcher")

    if [[ -n "$state" ]]; then
      local config_file="$PATH_DOCKERWEB_APPS/launcher/config.sh"
      local post_install_script="$PATH_DOCKERWEB_APPS/launcher/$FILENAME_POST_INSTALL"

      if [[ -f "$config_file" ]]; then
        source "$config_file"
      else
        echo "Error: Config file '$config_file' not found."
        return 1
      fi

      if [[ -f "$post_install_script" ]]; then
        bash "$post_install_script"
      else
        echo "Error: Post-install script '$post_install_script' not found."
        return 1
      fi
    fi
  fi
}
