REDIRECTION_TYPE() {
  local STR="$1"

  # Route locale
  if [[ "$STR" == /* ]]; then
    echo "route"
    return
  fi

  # Supprime le schéma http:// ou https:// pour analyse
  local STR_NO_SCHEME="${STR#http://}"
  STR_NO_SCHEME="${STR_NO_SCHEME#https://}"

  # Si après le domaine, il y a un / avec un chemin -> url
  if [[ "$STR_NO_SCHEME" =~ /.+ ]]; then
    echo "url"
  else
    # Sinon, c'est juste un domaine
    echo "domain"
  fi
}
