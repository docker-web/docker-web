<h1 align="center">
  <picture>
    <img align="center" alt="Pegaz" src="./docs/pegaz.svg" height="100">
  </picture>
  Pegaz
</h1>

## Install
`curl -sL get.pegaz.io | sudo bash`

## Deploy service
`pegaz up nextcloud`

## Create service
`pegaz create grav`

then you can edit config in services/grav/

## Features
- ssl certification
- sub-domain & multi-domain proxy
- pre & post install script
- backup / restore

## Introduction
Pegaz is a simple web-service launcher.

In extending docker-compose functionnality, pegaz let you control multiple docker-compose.yml configurations.

Pegaz add also a <b>proxy</b>, a <b>port manager</b> and a <b>backup system</b>.

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

## Configuration
### DNS
`A domain.com serverIP`
`A *.domain.com serverIP`
### Router Config
Redirect port 7700 to 8000
from all ip address to the serverIP address


## Whant to contribute ?
help is needed for those features :
- security test
- apply Docker secret
- Windows compatibility
- MacOS compatibility
- ARM compatibility
