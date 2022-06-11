#!/bin/bash
echo "${EMAIL} ${USER} ${PASS}" | docker exec penpot-backend /opt/penpot/backend/manage.sh create-profile
