#!/bin/bash
docker exec $1 sed -i 's/Welcome\ to\ nginx!/pegaz test page/' /usr/share/nginx/html/index.html
docker exec $1 sed -i 's/If you see this page/this file was edited with post-install.sh/' /usr/share/nginx/html/index.html
