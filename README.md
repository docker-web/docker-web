<h1 align="center">
  <picture>
<<<<<<< HEAD
    <img align="center" alt="pegaz.dev" src="./docs/docker-web.svg" height="100">
=======
    <img align="center" alt="docker-web.com" src="./docs/docker-web.svg" height="100">
>>>>>>> 78c5808 (pegaz -> docker-web)
	<h4 align="center" style="font-size: 20px">hackable self-hosting</h4>
  </picture>
</h1>

## Features
- 🔒 ssl certification
- 🎉 sub-domain & multi-domain directly in docker-compose file
- 📝 pre & post install script
- 📦 backup / restore volumes
- 🤖 pre-configure apps user account

## Install
`curl get.docker-web.com | bash`

## Deploy service
`docker-web up nextcloud`

![](https://raw.githubusercontent.com/docker-web/docker-web/master/docs/demo1.gif)

## Backup & Restore service
`docker-web backup  nextcloud`
`docker-web restore nextcloud`

![](https://raw.githubusercontent.com/docker-web/docker-web/master/docs/demo2.gif)
![](https://raw.githubusercontent.com/docker-web/docker-web/master/docs/storj.svg)

## Create service
`docker-web create $NAME`

![](https://raw.githubusercontent.com/docker-web/docker-web/master/docs/create.gif)
![](https://raw.githubusercontent.com/docker-web/docker-web/master/docs/dockerhub.svg)

## Dev
`git clone https://github.com/docker-web/docker-web.git`
`source get.docker-web.com`
now you can use the special command 'docker-webdev'
`docker-webdev ...`

## Introduction

In extending docker-compose functionnality, docker-web let you control multiple docker-compose.yml configurations.

docker-web add also a <b>proxy</b>, a <b>port manager</b> and a <b>backup system</b>.

The goal is to facilitate the deployment of web-services by :

1. Centralize docker-compose usage

An easiest way to deploy and manage apps, is containerization and docker-compose is a popular way to do it.
Docker-compose allow you to
 - launch multiple services at once
 - put all settings of your app in one file (infrastrucure as code)
 - set ports forwarding

The drawback of docker-compose is to launch services set in only one file.
Gathered all your apps settings in the same file make it difficult to maintain and manage one service at a time.

docker-web provide a command line interface to split services configurations but also to manage all of them with one command line interface.

2. Proxy & SSL certificates
    - automatic
    - sub domain
    - redirection

3. Create a service
    default configuration
    dockerhub functionnality
    quick way to test services
		try: `docker-web create ghost` or `docker-web create grav` or `docker-web create wordpress` or `docker-web create drupal`

4. Configure a service
    Custom Nginx Configuration
    port forwarding
    pre and post install script

## Why infrastructure as code ?
- easy to collaborate as all the settings are in the code repo
- easy to install & remove
- easy to backup
- easy for software upgrade
- easy for hardware upgrade

## Configuration
### DNS
`A domain.com serverIP`
`A *.domain.com serverIP`
### Router Config
Redirect port 7700 to 8112
from all ip address to the serverIP address

## TODO

- [ ] Email server https://github.com/docker-mailserver/docker-mailserver#examples
