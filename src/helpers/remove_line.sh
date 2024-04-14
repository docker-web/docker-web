REMOVE_LINE() {
  sed -i "/.*$1.*/d" $2 &> /dev/null
}
