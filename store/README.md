<h1 align="center">
  <picture>
    <img align="center" alt="docker-web" src="./logo.svg" height="100">
  </picture>
  Store
  <br>
  <br>
    <center>
    Store for Docker-web apps
  </center>
</h1>
<h4>
this folder is design to store docker-web apps,
an app is a pre-configured docker-compose web application following the structure details below.
</h4>
<h3>Structure:</h3>

```bash
 .
 ├─ app_name/
 │   ├── config.sh                      app configurations
 │   ├── docker-compose.yml             app docker structure
 │   ├── logo.svg                       app icon
 │   ├── nginx.conf                     nginx configurations (optional)
 │   ├── post-install.sh                script executed before the app is launched (optional)
 │   ├── pre-install.sh                 script executed after the app is launched (optional)
 │   └── README.md
 ├─ _archives/
 │   ├─ app-1.tar.gz              tarballs of apps ready to be downloaded from a docker-web instance (auto generated)
 │   ├─ app-2.tar.gz
 │   └─ index.json                              list of available apps in store (auto generated)
```
