#!/bin/bash

# Fonction pour cloner uniquement un sous-dossier d'un dépôt Git
clone_subdir() {
    local subdir="$1"
    local target_dir="$2"
    local tmp_dir
    
    tmp_dir=$(mktemp -d)
    
    # Cloner le dépôt de manière superficielle pour économiser de l'espace
    git clone --depth 1 --filter=blob:none --sparse "$URL_GITHUB" "$tmp_dir"
    
    # Se déplacer dans le dépôt cloné
    cd "$tmp_dir" || return 1
    
    # Configurer le sparse-checkout pour ne prendre que le dossier souhaité
    git sparse-checkout set "$subdir"
    
    # Créer le répertoire cible
    mkdir -p "$target_dir"
    
    # Copier le contenu du sous-dossier vers la cible
    cp -r "$subdir"/* "$target_dir"
    
    # Nettoyer
    cd /tmp || return 1
    rm -rf "$tmp_dir"
}

DL() {
  local APP_NAME="$1"
  local APP_DIR="${PATH_APPS}/${APP_NAME}"
  local APP_SUBDIR="apps/${APP_NAME}"
echo "APP_SUBDIR:" $APP_SUBDIR
  if [ -z "$APP_NAME" ]; then
    echo "Error: Please specify the application name"
    return 1
  fi

  if [ -d "$APP_DIR" ]; then
    # Demande de confirmation avant mise à jour
    read -p "The application $APP_NAME already exists. Do you want to update it? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      return 1
    fi

    echo "Updating application $APP_NAME..."

    # Sauvegarder les fichiers de configuration s'ils existent
    local temp_env=""
    local temp_dotenv=""

    if [ -f "${APP_DIR}/env.sh" ]; then
      temp_env=$(mktemp)
      cp "${APP_DIR}/env.sh" "$temp_env"
    fi

    if [ -f "${APP_DIR}/.env" ]; then
      temp_dotenv=$(mktemp)
      cp "${APP_DIR}/.env" "$temp_dotenv"
    fi

    # Créer un répertoire temporaire pour la mise à jour
    local TMP_UPDATE_DIR=$(mktemp -d)
    echo "APP_SUBDIR"
    echo "$APP_SUBDIR"
    # Cloner uniquement le dossier de l'application
    if clone_subdir "$APP_SUBDIR" "$TMP_UPDATE_DIR"; then
      # Supprimer l'ancien répertoire
      rm -rf "$APP_DIR"
      # Déplacer le nouveau contenu
      mkdir -p "$(dirname "$APP_DIR")"
      mv "$TMP_UPDATE_DIR" "$APP_DIR"
    else
      echo "Error while updating the application"
      rm -rf "$TMP_UPDATE_DIR"
      return 1
    fi

    # Restaurer les fichiers de configuration
    if [ -n "$temp_env" ] && [ -f "$temp_env" ]; then
      mv "$temp_env" "${APP_DIR}/env.sh"
    fi

    if [ -n "$temp_dotenv" ] && [ -f "$temp_dotenv" ]; then
      mv "$temp_dotenv" "${APP_DIR}/.env"
    fi

    echo "Update completed for $APP_NAME"
  else
    echo "Downloading application $APP_NAME..."
    
    # Créer le répertoire parent s'il n'existe pas
    mkdir -p "$(dirname "$APP_DIR")"
    
    # Utiliser la fonction clone_subdir pour le téléchargement initial
    if clone_subdir "$APP_SUBDIR" "$APP_DIR"; then    
      # Rendre les scripts exécutables
      find "$APP_DIR" -name "*.sh" -exec chmod +x {} \;

      echo "Application $APP_NAME successfully downloaded to $APP_DIR"
    else
      echo "Error: Application $APP_NAME does not exist in the repository or an error occurred"
      return 1
    fi
  fi
}