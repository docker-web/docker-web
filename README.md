<h1>
<picture>
  <img alt="Pegaz" src="./docs/pegaz.svg" height="100">
</picture>
</h1>

# Pegaz
A simple web-service launcher.


## Features

1. automatic ssl certification
2. automatic sub-domain & multi-domain proxy
3. easy proxy configuration
4. pre & post install script
5. easy backup / restore
6. customize services with docker-compose

### Deploy service

1. `pegaz config`
2. `pegaz up nextcloud`
3. click on service url

### Create service

1. `pegaz create grav`
2. click on service url
2. customize config in services/grav/


# Introduction

Pegaz is a docker-compose wrapper for self-hosted services.
The goal is to facilitate the deployment of web-services by :

1. Centralize docker-compose usage

An easiest way to deploy and manage apps, is containerization and docker-compose is a popular way to do it.
Docker-compose allow you to
 - launch multiple services at once
 - put all settings of your app in one file (infrastrucure as code)
 - set ports forwarding

The drawback of docker-compose is to launch services set in only one file.
Gathered all your apps settings in the same file make it difficult to maintain and manage one service at a time.

Pegaz providing a command line interface to split services configurations but also to manage all of them with one command line interface.

2. Proxy & SSL certificates
    automatic
    sub domain
    redirection

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

## Setup :

### Install
`sudo su`

`curl -sL get.pegaz.io | bash`

### DNS config

`A domain.com dist-ip`

`A *.domain.com dist-ip`
### Port config
7700 -> 8000
### Port redirect
from * to ip
