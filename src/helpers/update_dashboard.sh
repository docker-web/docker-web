UPDATE_DASHBOARD() {
  [[ $1 != "dashboard" && -n $(GET_STATE "dashboard") ]] && source "$PATH_DOCKERWEB_APPS/dashboard/config.sh" && bash "$PATH_DOCKERWEB_APPS/dashboard/$FILENAME_POST_INSTALL"
}
