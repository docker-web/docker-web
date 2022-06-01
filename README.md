# docker-compose wrapper for self-hosted servers

## PORT RANGES

7700 -> 8000
7700 -> 7709 reserved for proxy and test
7710 -> 7719 reserved for nextcloud

## pre-config :
DNS: A *.domain.com dist ip
PORT REDIRECT: from * to local ip

# WHY INFRASTRUCTURE AS CODE ?

- easy to collaborate as all the settings are in the code repo
- easy to install & remove
- easy to backup
- so easy to change hardware (free from hardware)
