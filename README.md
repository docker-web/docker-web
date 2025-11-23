<h1 align="center">
  <picture>
    <img align="center" alt="docker-web" src="./logo.svg" height="100">
  </picture>
  docker-web
</h1>

@TODO mettre en valeur les application ?

<h3>docker-web up</h3>

<img src="docs/demo1.gif">

<h3>docker-web backup</h3>
<img src="docs/demo2.gif">

<h2>Install</h2>

```bash
curl https://raw.githubusercontent.com/docker-web/docker-web/master/install.sh | bash
```

<h3>Manual</h3>

<h4>core</h4>

```bash
docker-web <command>

  help      -h       print help
  version   -v       print version
  upgrade            upgrade docker-web
  uninstall          uninstall docker-web
  config             configurations assistant
  ls                 list apps
```

<h4>app</h4>

```bash
docker-web <command> [app_name]

  up                 launch or update app
  create             create [app_name] [dockerhub_image_name]
  init               init app in the current directory
  reset              down app and remove containers and volumes
  backup             archive app
  restore            restore app
  rm                 reset app and remove its folder
  *                  restart stop down rm logs pull ...

```

<h3>structure</h3>

```bash
.
├── media                                  data folder
├── src                                    source code
├── template                               template for init app
├── config.sh                              user configurations
└── apps                                   apps configurations
    ├─ app_name/
    │   ├── env.sh                         environment variables
    │   ├── docker-compose.yml             docker stack structure
    │   ├── logo.svg                       app icon
    │   ├── nginx.conf                     nginx configurations (optional)
    │   ├── post-install.sh                script executed before launching app (optional)
    │   ├── pre-install.sh                 script executed after launching app (optional)
    │   └── README.md
```
