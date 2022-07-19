#!/bin/bash
# SSH Container Passthrough 

sudo useradd git
sudo chown -R git:git /home/git/

GIT_UID=$(id -u git)
GIT_GID=$(id -g git)

sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key" -N "" -f "/home/git/.ssh/id_rsa" -y
sudo -u git cat /home/git/.ssh/id_rsa.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys
sudo -u git chmod 750 /home/git/.ssh/authorized_keys

sudo echo -e "#!/bin/bash
ssh -p ${PORT_SSH} -o StrictHostKeyChecking=no git@127.0.0.1 \"SSH_ORIGINAL_COMMAND=\\\"\$SSH_ORIGINAL_COMMAND\\\" \$0 \$@\"" | sudo tee /usr/local/bin/gitea

sudo chmod +x /usr/local/bin/gitea

[[ $IS_PEGAZDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"
