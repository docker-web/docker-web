UPGRADE() {
  echo "[i] Upgrade while keeping config.sh and custom apps"

  # Store the current docker-web version
  OLD_DOCKERWEB_VERSION=$DOCKERWEB_VERSION

  # Remove any previous temporary clone
  rm -rf /tmp/docker-web

  # Clone the latest docker-web repository (shallow clone)
  git clone --depth 1 "$URL_DOCKERWEB_GITHUB" /tmp/docker-web

  # Remove the old docker-web files but keep config.sh and apps directory
  # Requires bash 4+ for extglob support
  rm -rf "$PATH_DOCKERWEB"/!(config.sh|apps)

  # Copy all files from the new repository into the docker-web path
  cp -a /tmp/docker-web/* "$PATH_DOCKERWEB/"

  # Reload environment variables if env.sh exists
  [[ -f "$PATH_DOCKERWEB/env.sh" ]] && source "$PATH_DOCKERWEB/env.sh"

  echo "[√] docker-web is now upgraded (v$OLD_DOCKERWEB_VERSION -> v$DOCKERWEB_VERSION)"
}
