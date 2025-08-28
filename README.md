<h1 align="center">
  <picture>
    <img align="center" alt="docker-web" src="./logo.svg" height="100">
  </picture>
  Docker-Web
  <br>
  <br>
    <center>
    A cli for self-hosted docker compose.yaml stack-oriented manager.
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
  create             create <app_name> <dockerhub_image_name> (based on https://github.com/docker-web/store/tree/main/apps/template)
  init               init app in the current directory (based on https://github.com/docker-web/store/tree/main/apps/template)
  backup             archive app in backup folder (for distant backup '--remote user@server.domain')
  restore            restore app (for distant restore '--remote user@server.domain')
  ls                 list app(s) running
  reset              down app and remove containers and volumes
  rm                 reset app and remove its folder
  *                  restart stop down rm logs pull ... any docker-compose commands are compatible
```

<h3>Tree</h3>

```bash
.
├── config.sh                              user configurations
├── apps                                   active apps folder
├── media                                  media datas folder
└── backup                                 backed-up apps folder
```

<h3>Demos:</h3>

<h4>Start/stop a service:</h4>
<img src="docs/demo1.gif">
<h4>Backup/restore a service:</h4>
<img src="docs/demo2.gif">
