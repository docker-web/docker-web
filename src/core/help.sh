HELP() {
  echo "docker-web v$DOCKERWEB_VERSION
apps available:
$APPS_FLAT

docker-web <command>

  help      -h       print help
  version   -v       print version
  upgrade            upgrade docker-web
  uninstall          uninstall docker-web
  config             configurations assistant
  ls                 list apps

docker-web <command> [app_name]

  up                 launch or update app
  create             create [app_name] [dockerhub_image_name]
  init               init [app_name] [type]
  backup             archive app
  restore            restore app
  reset              down app and remove containers and volumes
  rm                 reset app and remove its folder
  *                  restart stop down rm logs pull ...
"
}
