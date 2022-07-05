#!/bin/bash
docker exec -it gitea gitea admin user create --email $EMAIL --password $PASSWORD --name $USERNAME
