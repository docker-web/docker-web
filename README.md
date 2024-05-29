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
  config             Assistant to edit configurations stored in config.sh

App Commands:
usage: docker-web <command> <app_name>
       docker-web <command> (command will be apply for all apps)

  up                 launch or update app
  create             create <app_name> <dockerhub_image_name> (based on /template)
  init               init app in the current directory (based on /template)
  backup             archive app in backup folder (send to storj if configured)
  restore            restore app (copy-back from storj if configured)
  ls                 list app(s) running
  rm                 down app and remove its config folder
  reset              down app and prune containers, images and volumes
  *                  restart stop down rm logs pull ... any docker-compose commands are compatible

App structure:
.
├── config.sh                              user configurations
├── apps
│   ├── app-1
│   │   ├── config.sh                      app configurations
│   │   ├── docker-compose.yml             app docker structure
│   │   ├── logo.svg                       icon of the app, usefull for dashboard
│   │   ├── nginx.conf                     nginx configurations (optional)
│   │   ├── post-install.sh                script executed before the app is launched (optional)
│   │   ├── pre-install.sh                 script executed after the app is launched (optional)
│   │   └── README.md
│   └── app-2
│       └── ...
└── backup
    ├── app-1.tar.gz
    │   ├── app-1_data.tar.gz
    │   ├── app-1_db.tar.gz
    │   └── app.tar.gz
│   └── ...
```
