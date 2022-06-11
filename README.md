# docker-compose wrapper for self-hosted services

## PORT RANGES
7700 -> 8000
7701 -> 7702 reserved for proxy
7703 -> 7709 reserved for test
7710 -> 7719 reserved for nextcloud
7720 -> 7729 reserved for penpot

## pre-config :
DNS: A *.domain.com dist ip
PORT REDIRECT: from * to self-ip

# WHY INFRASTRUCTURE AS CODE ?
- easy to collaborate as all the settings are in the code repo
- easy to install & remove
- easy to backup
- so easy to change hardware (free from hardware)
