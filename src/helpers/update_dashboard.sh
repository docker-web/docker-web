UPDATE_DASHBOARD() {
  [[ $1 != "dashboard" && -n $(GET_STATE "dashboard") ]] && source "$PATH_DOCKERWEB_SERVICES/dashboard/config.sh" && bash "$PATH_DOCKERWEB_SERVICES/dashboard/$FILENAME_POST_INSTALL"
}
