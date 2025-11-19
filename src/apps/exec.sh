EXEC() {
  docker exec -it $1 sh || echo "$1 is not initialized"
}
