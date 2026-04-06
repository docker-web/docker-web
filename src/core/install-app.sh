#!/bin/bash

INSTALL_PRECONFIGURED_APP() {
  local APP_NAME=$1
  local APPS_DIR="$PATH_DOCKERWEB/apps"
  local TMP_FOLDER="/tmp/docker-web-apps"
  
  if [[ -z "$APP_NAME" ]]; then
    echo "[x] Veuillez spécifier un nom d'application: docker-web install <app_name>"
    echo "[i] Apps préconfigurées disponibles: code, excalidraw, ersatztv, fail2ban, gitea, jellyfin, nextcloud, penpot, transmission, umami"
    return 1
  fi
  
  # Vérifier si l'app n'existe pas déjà
  if [[ " ${APPS_FLAT[*]} " =~ " $APP_NAME " ]]; then
    echo "[x] L'application $APP_NAME existe déjà"
    return 1
  fi
  
  # Liste des apps préconfigurées disponibles
  local PRECONFIGURED_APPS=("code" "excalidraw" "ersatztv" "fail2ban" "gitea" "jellyfin" "nextcloud" "penpot" "transmission" "umami")
  
  if [[ ! " ${PRECONFIGURED_APPS[*]} " =~ " $APP_NAME " ]]; then
    echo "[x] L'application $APP_NAME n'est pas une app préconfigurée disponible"
    echo "[i] Apps préconfigurées disponibles: ${PRECONFIGURED_APPS[*]}"
    return 1
  fi
  
  # Télécharger et extraire l'app depuis le repo GitHub
  echo "[*] Téléchargement de l'application préconfigurée: $APP_NAME"
  
  rm -rf $TMP_FOLDER
  mkdir -p $TMP_FOLDER
  
  # Télécharger uniquement le dossier de l'application
  git clone --depth 1 --filter=blob:none --sparse $URL_GITHUB $TMP_FOLDER
  cd $TMP_FOLDER
  git sparse-checkout set "apps/$APP_NAME"
  
  # Copier l'application dans le dossier apps
  if [ -d "$TMP_FOLDER/apps/$APP_NAME" ]; then
    cp -r "$TMP_FOLDER/apps/$APP_NAME" "$APPS_DIR/"
    echo "[√] Application $APP_NAME installée avec succès"
    
    # Recharger les variables d'environnement
    source $PATH_DOCKERWEB/src/env.sh
  else
    echo "[x] Impossible de trouver l'application $APP_NAME dans le dépôt"
    rm -rf $TMP_FOLDER
    return 1
  fi
  
  # Nettoyer
  rm -rf $TMP_FOLDER
  
  echo "[i] Vous pouvez maintenant configurer et démarrer l'application avec:"
  echo "    docker-web up $APP_NAME"
}
