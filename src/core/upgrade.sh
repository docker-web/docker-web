UPGRADE() {
  echo "[i] Upgrade while keeping env files and custom apps"

  # Enable extended pattern matching
  shopt -s extglob

  # Store the current docker-web version
  OLD_DOCKERWEB_VERSION=$DOCKERWEB_VERSION

  # Remove any previous temporary clone
  rm -rf /tmp/docker-web

  # Clone the latest docker-web repository (shallow clone)
  git clone --depth 1 "$URL_DOCKERWEB_GITHUB" /tmp/docker-web

  # Remove the default docker-web env.sh, .env and store directory
  # Using a more compatible approach with find
  find /tmp/docker-web -type f \( -name "env.sh" -o -name ".env" -o -name "config.sh" \) -delete
  rm -rf /tmp/docker-web/store

  # Copy all files from the new repository into the docker-web path
  cp -a /tmp/docker-web/* "$PATH_DOCKERWEB/"

  # Reload environment variables using HAS_ENV_FILE
  local env_file
  env_file=$(HAS_ENV_FILE "$PATH_DOCKERWEB")
  [[ -n "$env_file" ]] && source "$env_file"

  echo "[√] docker-web is now upgraded (v$OLD_DOCKERWEB_VERSION -> v$DOCKERWEB_VERSION)"
}
