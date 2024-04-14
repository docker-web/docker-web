FUNCTION_EXISTS() {
  declare -f -F "$1" > /dev/null
  return $?
}
