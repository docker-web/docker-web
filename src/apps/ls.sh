LS() {
  local STATE_APP=$(GET_STATE $1)
  if [[ -n $STATE_APP ]]
  then
    SOURCE_APP $1
    printf "%-20s %-20s %-20s\n" $1 $PORT $STATE_APP  
  fi
}
