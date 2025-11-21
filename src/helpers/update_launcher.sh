UPDATE_LAUNCHER() {
  if [[ "$1" != "launcher" ]]; then
    local state
    state=$(GET_STATE "launcher")

    if [[ -n "$state" ]]; then
      local env_file
      env_file=$(HAS_ENV_FILE "$PATH_APPS/launcher")
      local post_install_script="$PATH_APPS/launcher/$FILENAME_POSTINSTALL"

      if [[ -n "$env_file" ]]; then
        source "$env_file"
      else
        echo "Error: env file not found in launcher directory."
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
