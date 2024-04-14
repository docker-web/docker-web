UPDATE() {
  EXECUTE "pull"  $1
  EXECUTE "build --pull" $1
  EXECUTE "up -d" $1
  UPDATE_DASHBOARD $1
  SERVICE_INFOS $1
}
