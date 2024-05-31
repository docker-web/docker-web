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
  config             Assistant to edit configurations stored in $FILENAME_CONFIG (specific configurations if app named is passed)

App Commands:
usage: docker-web <command> <app_name>
       docker-web <command> (command will be apply for all apps)

  up                 launch or update a web app with configuration set in $FILENAME_CONFIG and proxy settings set in $FILENAME_NGINX then execute $FILENAME_POST_INSTALL
  create             create an app from a dockerhub image (based on /template) (docker-web create <app_name> <dockerhub_image_name>)
  init               init docker-web ci in the current directory (based on /template)
  backup             archive app (named volumes + config folder) in $PATH_DOCKERWEB_BACKUP (send to storj if configured)
  restore            restore app archived (copy-back from storj if configured)
  ls                 list app(s) running
  rm                 down app and remove its config folder
  reset              down app and prune containers, images and volumes
  *                  restart stop down rm logs pull ... any docker-compose commands are compatible
"
}
