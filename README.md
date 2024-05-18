<h1 align="center">
  <picture>
    <img align="center" alt="docker-web" src="./logo.svg" height="100">
  </picture>
  docker-web
</h1>

```bash
Core Commands:
usage: docker-web <command>

  help      -h       Print help
  version   -v       Print version
  upgrade            Upgrade docker-web
  uninstall          Uninstall docker-web
  config             Assistant to edit configurations stored in config.sh (specific configurations if service named is passed)

Service Commands:
usage: docker-web <command> <service_name>
       docker-web <command> (command will be apply for all services)

  up                 launch or update a web service with configuration set in config.sh and proxy settings set in nginx.conf then execute post-install.sh
  create             create a service from a dockerhub image (based on /template) (docker-web create <service_name> <dockerhub_image_name>)
  init               init docker-web ci in the current directory (based on /template)
  backup             archive volume(s) mounted on the service in ~/docker-web/backup (send to storj if configured)
  restore            replace volume(s) mounted on the service by backed up archive (copy-back from storj if configured)
  reset              down a service and prune containers, images and volumes not linked to up & running containers (useful for dev & test)
  drop               down a service and remove its config folder
  *                  restart stop down rm logs pull ... any docker-compose commands are compatible

.
├── config.sh                              user configurations
├── apps
│   ├── app-1
│   │   ├── config.sh                      app configurations
│   │   ├── docker-compose.yml             app services structure
│   │   ├── logo.svg                       icon of the service, usefull for dashboard
│   │   ├── nginx.conf                     nginx configurations (optional)
│   │   ├── post-install.sh                script executed before the service is launched (optional)
│   │   ├── pre-install.sh                 script executed after the service is launched (optional)
│   │   └── README.md
│   ├── app-2
│   │   ├── ...
├── backup
│   ├── app-1.tar.gz
│   └── app-2.tar.gz
```
