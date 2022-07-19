# docker-compose wrapper for self-hosted services

Pegaz is meant to facilitate the deployment of web-services by:

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

## pre-config :
DNS: A *.domain.com dist ip
## PORT RANGES
7700 -> 8000
PORT REDIRECT: from * to ip

# WHY INFRASTRUCTURE AS CODE ?
- easy to collaborate as all the settings are in the code repo
- easy to install & remove
- easy to backup
- so easy to change hardware (free from hardware)

# Whant to contribute ?
help is needed for those features :
- security test
- apply docker secret
- windows compatibility ?
- osx compatibility ?
