DL() {
  local app="$1"
  local url
  if command -v jq >/dev/null 2>&1; then
    url=$(jq -r ".apps[] | select(.name==\"$app\") | .url" "$PATH_DOCKERWEB/store/index.json")
  else
    url=$(grep -oP '"name"\s*:\s*"'$app'".*?"url"\s*:\s*"\K[^"]+' "$PATH_DOCKERWEB/store/index.json")
  fi

  if [ -z "$url" ]; then
    echo "❌ $app non trouvé dans le store"
    return 1
  fi

  echo "Téléchargement de $app depuis $url..."
  mkdir -p "$PATH_DOCKERWEB_APPS"
  curl -L "$url" -o "/tmp/${app}.tar.gz"
  tar -xzf "/tmp/${app}.tar.gz" -C "$PATH_DOCKERWEB_APPS"
  rm "/tmp/${app}.tar.gz"
  echo "✅ $app installé"
}
