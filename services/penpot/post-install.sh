#!/bin/bash
echo "${EMAIL} ${USERNAME} ${PASSWORD}" | docker exec penpot-backend /opt/penpot/backend/manage.sh create-profile
