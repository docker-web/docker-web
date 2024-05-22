START() {
  [[ -z $(GET_STATE $1) ]] && UP $1 || EXECUTE "start" $1
}
