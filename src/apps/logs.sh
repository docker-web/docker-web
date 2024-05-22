LOGS() {
  [[ -n $(GET_STATE $1) ]] && EXECUTE "logs -f" $1 || echo "$1 is not initialized"
}
