#!/bin/bash

if ! command -v sudo 1>/dev/null
then
echo "[*] install sudo"
command -v apt 1>/dev/null && apt update --allow-releaseinfo-change -y && apt -y install sudo
command -v apk 1>/dev/null && apk update && apk add sudo
command -v pacman 1>/dev/null && pacman -Sy --noconfirm sudo
command -v yum 1>/dev/null && yum -y update && yum -y install sudo
fi

# SSH Container Passthrough
sudo useradd git
sudo chown -R git:git /home/git/
sudo -u git touch /home/git/.ssh/id_rsa
sudo -u git chmod 600 /home/git/.ssh/id_rsa
sudo -u git ssh-keygen -q -t rsa -b 4096 -C "Gitea Host Key" -N "" -f /home/git/.ssh/id_rsa <<<y >/dev/null 2>&1
sudo -u git cat /home/git/.ssh/id_rsa.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys > /dev/null
sudo -u git chmod 750 /home/git/.ssh/authorized_keys
sudo echo -e "#!/bin/bash
ssh -p ${PORT_SSH} -o StrictHostKeyChecking=no git@127.0.0.1 \"SSH_ORIGINAL_COMMAND=\\\"\$SSH_ORIGINAL_COMMAND\\\" \$0 \$@\"" | sudo tee /usr/local/bin/gitea > /dev/null
sudo chmod +x /usr/local/bin/gitea

# switch between http / https dev / prod
[[ $IS_PEGAZDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"

# drone config
DRONE_RPC_SECRET=$(openssl rand -hex 16)
sed -i "s/DRONE_RPC_SECRET=.*/DRONE_RPC_SECRET=\"$DRONE_RPC_SECRET\"/" "$PATH_PEGAZ_SERVICES/$1/config.sh"
