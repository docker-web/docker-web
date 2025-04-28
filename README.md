<h1 align="center">
  <picture>
    <img align="center" alt="docker-web" src="./logo.svg" height="100">
  </picture>
  docker-web
  <br>
  <br>
    <center>
    manage web-app with docker
  </center>
</h1>

<h2>Install</h2>

```bash
curl https://raw.githubusercontent.com/docker-web/docker-web/master/install.sh | bash
```

<h3>Manual</h3>

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
  reset              down app and remove containers and volumes
  rm                 down app and remove its config folder
  *                  restart stop down rm logs pull ... any docker-compose commands are compatible
```

<h3>App structure:</h3>

```bash
.
├── config.sh                              user configurations
├── apps
│   ├── app-1
│   │   ├── config.sh                      app configurations
│   │   ├── docker-compose.yml             app docker structure
│   │   ├── logo.svg                       app icon (usefull for launcher app)
│   │   ├── nginx.conf                     nginx configurations (optional)
│   │   ├── post-install.sh                script executed before the app is launched (optional)
│   │   ├── pre-install.sh                 script executed after the app is launched (optional)
│   │   └── README.md
│   └── app-2
│       └── ...
└── backup
    ├── app-1.tar.gz
    │   ├── app-1_volume-1.tar.gz
    │   ├── app-1_volume-2.tar.gz
    │   └── app.tar.gz
│   └── ...
```

<h3>Demos:</h3>

<h4>Start/stop a service:</h4>
<img src="docs/demo1.gif">
<h4>Backup/restore a service:</h4>
<img src="docs/demo2.gif">
