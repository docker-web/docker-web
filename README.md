<h1>
  <picture>
    <img align="center" alt="Pegaz" src="./docs/pegaz.svg" height="100">
  </picture>
  Pegaz
  <i style="font-size:16px">
    A simple web-service launcher.
  </i>
</h1>

### Install
`curl -sL get.pegaz.io | sudo bash`
### DNS
`A domain.com ip`
`A *.domain.com ip`
### Ports
7700 -> 8000
### Redirect
from * to ip

## Features

1. ssl certification
2. sub-domain & multi-domain proxy
3. pre & post install script
4. backup / restore

### Deploy service

1. `pegaz config`
2. `pegaz up nextcloud`

### Create service

1. `pegaz create grav`
2. edit config in services/grav/

# Introduction

Pegaz is a docker-compose wrapper for self-hosted services.

It means that pegaz add functionnality to docker-compose cli.
Docker-compose cli let you control only one file, pegaz can manage several one.

Pegaz add a proxy and automatic port manager and a volume backup / restore.
The goal is to facilitate the deployment of web-services by :

1. Centralize docker-compose usage

An easiest way to deploy and manage apps, is containerization and docker-compose is a popular way to do it.
Docker-compose allow you to
 - launch multiple services at once
 - put all settings of your app in one file (infrastrucure as code)
 - set ports forwarding

The drawback of docker-compose is to launch services set in only one file.
Gathered all your apps settings in the same file make it difficult to maintain and manage one service at a time.

Pegaz provide a command line interface to split services configurations but also to manage all of them with one command line interface.

2. Proxy & SSL certificates
    - automatic
    - sub domain
    - redirection

3. Create a service
    default configuration
    dockerhub functionnality
    quick way to test services

4. Configure a service
    Custom Nginx Configuration
    port forwarding
    pre and post install script

## Why infrastructure as code ?
- easy to collaborate as all the settings are in the code repo
- easy to install & remove
- easy to backup
- so easy to change hardware (free from hardware)


## Whant to contribute ?
help is needed for those features :
- security test
- apply Docker secret
- Windows compatibility
- MacOS compatibility
- ARM compatibility
