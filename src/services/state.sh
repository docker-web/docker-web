STATE() {
  local STATE_SERVICE=$(GET_STATE $1)
  if [[ -n $STATE_SERVICE ]]
  then
    SOURCE_SERVICE $1
    printf "%-20s %-20s %-20s\n" $1 $PORT $STATE_SERVICE  
  fi
}
