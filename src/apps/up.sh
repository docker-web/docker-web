UP() {
  ADD_TO_HOSTS $1
  SETUP_PROXY
  PRE_INSTALL $1
  EXECUTE "pull"  $1
  EXECUTE "build" $1
  EXECUTE "up -d" $1
  POST_INSTALL $1
  UPDATE_LAUNCHER $1
  APP_INFOS $1
}
