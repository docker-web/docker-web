#!/bin/bash

docker cp $PATH_PEGAZ/docs/pegaz.svg $1:/usr/share/nginx/html/
docker exec $1 sed -i "0,/<body>/s//<body>\n<img style=\"width:100%\" src=\"https:\/\/raw.githubusercontent.com\/valerebron\/pegaz\/master\/docs\/pegaz.svg\"\/>/" "/usr/share/nginx/html/index.html"
docker exec $1 sed -i 's/Welcome\ to\ nginx!/pegaz test page/' /usr/share/nginx/html/index.html
docker exec $1 sed -i 's/If you see this page/this file was edited with post-install.sh/' /usr/share/nginx/html/index.html
