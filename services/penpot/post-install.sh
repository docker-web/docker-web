#!/bin/bash
docker exec penpot-backend python3 ./manage.py -e $EMAIL -p $PASSWORD -n $USERNAME create-profile
break &> /dev/null
