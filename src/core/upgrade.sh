UPGRADE() {
  # Store the current docker-web version
  OLD_VERSION=$NEW_VERSION

  # Remove any previous temporary clone
  rm -rf /tmp/docker-web

  # Clone the latest docker-web repository (shallow clone)
  git clone --depth 1 "$URL_DOCKERWEB_GITHUB" /tmp/docker-web
  rm /tmp/docker-web/config.sh
  # Copy all files from the new repository into the docker-web path
  cp -a /tmp/docker-web/* "$PATH_DOCKERWEB/"
  echo "[√] docker-web is now upgraded (v$OLD_VERSION -> v$NEW_VERSION)"
}
