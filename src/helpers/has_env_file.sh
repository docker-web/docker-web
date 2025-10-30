# Vérifie si un dossier d'application contient un fichier d'environnement
HAS_ENV_FILE() {
  local app_dir="$1"

  if [[ -f "$app_dir/env.sh" ]]; then
    echo "$app_dir/env.sh"
    return 0
  fi

  return 1
}
