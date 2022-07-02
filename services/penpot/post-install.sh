#!/bin/bash
sleep 4
docker exec penpot-backend ./manage.sh --email $EMAIL --password $PASSWORD --name $USERNAME create-profile
