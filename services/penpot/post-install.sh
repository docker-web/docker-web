#!/bin/bash
docker exec -it penpot-backend echo "${EMAIL} ${USER} ${PASS}" | ./manage.sh create-profile
