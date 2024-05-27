source ~/docker-web/config.sh

GITEA() {
  docker exec gitea gitea $1
}


GITEA "admin user create --admin --username $USERNAME --password $PASSWORD --email $EMAIL --must-change-password=false"

TOKEN=$(GITEA "--config /etc/gitea/app.ini actions generate-runner-token")
[[ $TOKEN != *\"* ]] && sed -i "s|REGISTRATION_TOKEN=.*|REGISTRATION_TOKEN=\"$TOKEN\"|g" $PATH_DOCKERWEB_APPS/gitea/config.sh
bash ~/docker-web/src/cli.sh restart gitea
