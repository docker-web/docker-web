#!/bin/bash

GITEA() {
  docker exec -u git gitea gitea $1
}

if ! command -v sudo 1>/dev/null
then
    echo "[*] install sudo"
    command -v apt 1>/dev/null && apt update --allow-releaseinfo-change -y && apt -y install sudo
    command -v apk 1>/dev/null && apk update && apk add sudo
    command -v pacman 1>/dev/null && pacman -Sy --noconfirm sudo
    command -v yum 1>/dev/null && yum -y update && yum -y install sudo
fi

# SSH Container Passthrough
sudo useradd git >/dev/null 2>&1
sudo chown -R git:git /home/git/
sudo -u git touch /home/git/.ssh/id_rsa
sudo -u git chmod 600 /home/git/.ssh/id_rsa
sudo -u git chmod 600 /home/git/.ssh/authorized_keys
sudo -u git chown -R git:git /home/git/
sudo -u git ssh-keygen -q -t rsa -b 4096 -C "Gitea Host Key" -N "" -f /home/git/.ssh/id_rsa <<<y > /dev/null
sudo -u git cat /home/git/.ssh/id_rsa.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys > /dev/null
sudo echo -e "#!/bin/bash
ssh -p ${PORT_SSH} -o StrictHostKeyChecking=no git@127.0.0.1 \"SSH_ORIGINAL_COMMAND=\\\"\$SSH_ORIGINAL_COMMAND\\\" \$0 \$@\"" | sudo tee /usr/local/bin/gitea > /dev/null
sudo chmod +x /usr/local/bin/gitea

sleep 8
GITEA "admin create-user --admin --username $USERNAME --password $PASSWORD --email $EMAIL --must-change-password=false"
echo "..."  # do not delete, used to force continue script if create-user failed 

# Manual Drone configuration :
# Create OAuth2 Applications via web ui:
# name: drone, redirect uri: http://drone.domain.com/login
# Copy ID & SECRET to config.sh
# restart drone:
# source config.sh && source services/gitea/config.sh && docker-compose -f services/gitea/docker-compose.yml up -d drone
