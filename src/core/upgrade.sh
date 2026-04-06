UPGRADE() {
  local OLD_VERSION TMP_FOLDER USER_APPS

  OLD_VERSION=$DOCKERWEB_VERSION
  TMP_FOLDER=/tmp/docker-web

  rm -rf $TMP_FOLDER
  mkdir $TMP_FOLDER

  git clone --depth 1 $URL_GITHUB $TMP_FOLDER

  # protect user configurations
  rm $TMP_FOLDER/config.sh
  
  # Protéger les applications utilisateur (sauf proxy et launcher)
  USER_APPS=$(find "$PATH_APPS" -mindepth 1 -maxdepth 1 -type d -not -name "proxy" -not -name "launcher" -exec basename {} \;)
  if [[ -n "$USER_APPS" ]]; then
    echo "[*] Sauvegarde des applications utilisateur: $USER_APPS"
    mkdir -p "$TMP_FOLDER/user_apps_backup"
    for app in $USER_APPS; do
      if [ -d "$PATH_APPS/$app" ]; then
        cp -r "$PATH_APPS/$app" "$TMP_FOLDER/user_apps_backup/"
      fi
    done
  fi

  # Supprimer les apps préconfigurées du dossier temporaire avant la copie
  if [ -d "$TMP_FOLDER/apps" ]; then
    find "$TMP_FOLDER/apps" -mindepth 1 -maxdepth 1 -type d -not -name "proxy" -not -name "launcher" -exec rm -rf {} +
  fi

  cp -a $TMP_FOLDER/* "$PATH_DOCKERWEB/"

  # Restaurer les applications utilisateur
  if [[ -n "$USER_APPS" ]] && [ -d "$TMP_FOLDER/user_apps_backup" ]; then
    echo "[*] Restauration des applications utilisateur"
    cp -r $TMP_FOLDER/user_apps_backup/* "$PATH_APPS/"
    rm -rf "$TMP_FOLDER/user_apps_backup"
  fi

  source $PATH_DOCKERWEB/src/env.sh
  echo "[√] docker-web is now upgraded (v$OLD_VERSION -> v$DOCKERWEB_VERSION)"
}
