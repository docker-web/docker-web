HELP() {
  echo "docker-web v$DOCKERWEB_VERSION
apps available:
$APPS_FLAT

Core Commands:
usage: docker-web <command>

  help      -h       Print help
  version   -v       Print version
  upgrade            Upgrade docker-web
  uninstall          Uninstall docker-web
  config             Assistant to edit configurations stored in config.sh

App Commands:
usage: docker-web <command> <app_name>
       docker-web <command> (command will be apply for all apps)

  up                 launch or update app
  create             create <app_name> <dockerhub_image_name> (based on https://github.com/docker-web/store/tree/main/apps/template)
  init               init app in the current directory (based on https://github.com/docker-web/store/tree/main/apps/template)
  backup             archive app in backup folder (for distant backup '--remote user@server.domain')
  restore            restore app (for distant restore '--remote user@server.domain')
  ls                 list app(s) running
  reset              down app and remove containers and volumes
  rm                 reset app and remove its folder
  *                  restart stop down rm logs pull ... any docker-compose commands are compatible
"
}
