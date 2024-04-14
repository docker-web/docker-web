RESET() {
  EXECUTE "stop" $1
  EXECUTE "rm -f" $1
}
