#!/bin/bash
GITEA() {
    docker exec gitea gitea $1
}
GENERATE_TOKEN() {
  echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $1 | head -n 1 | tr -d '\n')
}

# CONFIGURE
# cp $PATH_DOCKERWEB_APPS/gitea/gitea.ini $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${USERNAME}/$USERNAME/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${EMAIL}/$EMAIL/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${PASSWORD}/$PASSWORD/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${PROTO}/$PROTO/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${PORT}/$PORT/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${PORT_DB}/$PORT_DB/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${DOMAIN}/$DOMAIN/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${PORT_SSH}/$PORT_SSH/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${PORT_SSH_EXPOSED}/$PORT_SSH_EXPOSED/g" $PATH_DOCKERWEB_APPS/gitea/app.ini

# sed -i "s/\${LFS_JWT_SECRET}/$(GENERATE_TOKEN 43)/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${INTERNAL_TOKEN}/$(GENERATE_TOKEN 36).$(GENERATE_TOKEN 24).$(GENERATE_TOKEN 43)/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# sed -i "s/\${JWT_SECRET}/$(GENERATE_TOKEN 43)/g" $PATH_DOCKERWEB_APPS/gitea/app.ini
# docker cp $PATH_DOCKERWEB_APPS/gitea/app.ini gitea:/etc/gitea/app.ini
# rm $PATH_DOCKERWEB_APPS/gitea/app.ini
# bash "$PATH_DOCKERWEB/src/cli.sh" restart gitea

# SSH Container Passthrough
sudo useradd --create-home git >/dev/null 2>&1
sudo chown -R git:git /home/git/
sudo -u git touch /home/git/.ssh/id_rsa
sudo -u git chmod 600 /home/git/.ssh/id_rsa
sudo -u git chown -R git:git /home/git/
sudo -u git ssh-keygen -q -t rsa -b 4096 -C "Gitea Host Key" -N "" -f /home/git/.ssh/id_rsa <<<y > /dev/null
sudo -u git cat /home/git/.ssh/id_rsa.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys > /dev/null
sudo echo -e "#!/bin/bash
ssh -p ${PORT_SSH} -o StrictHostKeyChecking=no git@127.0.0.1 \"SSH_ORIGINAL_COMMAND=\\\"\$SSH_ORIGINAL_COMMAND\\\" \$0 \$@\"" | sudo tee /usr/local/bin/gitea > /dev/null
sudo chmod +x /usr/local/bin/gitea
docker exec gitea chown -R git:git /data/git/.ssh

# sleep 7

# CREATE USER
GITEA "admin user create --admin --username $USERNAME --password $PASSWORD --email $EMAIL --must-change-password=false"

# RUNNER TOKEN
TOKEN=$(GITEA "--config /etc/gitea/app.ini actions generate-runner-token") && echo "token generation success"
sed -i "s|TOKEN=.*|TOKEN=\"$TOKEN\"|g" $PATH_DOCKERWEB_APPS/gitea/config.sh

source $PATH_DOCKERWEB/src/helpers/execute.sh
source $PATH_DOCKERWEB/src/helpers/test_config.sh
EXECUTE "up -d gitea-runner" "gitea"
