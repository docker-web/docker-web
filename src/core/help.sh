HELP() {
  echo "docker-web v$DOCKERWEB_VERSION
services:
$SERVICES_FLAT

Core Commands:
usage: docker-web <command>

  help      -h       Print help
  version   -v       Print version
  upgrade            Upgrade docker-web
  uninstall          Uninstall docker-web
  config             Assistant to edit configurations stored in $FILENAME_CONFIG (specific configurations if service named is passed)

Service Commands:
usage: docker-web <command> <service_name>
       docker-web <command> (command will be apply for all services)

  up                 launch or update a web service with configuration set in $FILENAME_CONFIG and proxy settings set in $FILENAME_NGINX then execute $FILENAME_POST_INSTALL
  create             create a service from a dockerhub image (based on /template) (docker-web create <service_name> <dockerhub_image_name>)
  init               init docker-web ci in the current directory (based on /template)
  backup             archive volume(s) mounted on the service in $PATH_DOCKERWEB_BACKUP (send volume(s) to storj if configured)
  restore            replace volume(s) mounted on the service by backed up archive in $PATH_DOCKERWEB_BACKUP (copy-back volume(s) from storj if configured)
  reset              down a service and prune containers, images and volumes not linked to up & running containers (useful for dev & test)
  drop               down a service and remove its config folder
  *                  restart stop down rm logs pull ... any docker-compose commands are compatible
"
}
