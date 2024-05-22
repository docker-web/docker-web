#!/bin/bash

set -e

docker exec code sudo apt upgrade -y
docker exec code curl -sL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh
docker exec code sudo bash /tmp/nodesource_setup.sh
docker exec code sudo apt install -y nodejs
