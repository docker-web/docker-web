#!/bin/bash

sudo useradd git
sudo chown -R git:git /home/git/

# SSH Container Passthrough
sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key" -N "" -f "/home/git/.ssh/id_rsa" -y > /dev/null
sudo -u git cat /home/git/.ssh/id_rsa.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys > /dev/null
sudo -u git chmod 750 /home/git/.ssh/authorized_keys
sudo echo -e "#!/bin/bash
ssh -p ${PORT_SSH} -o StrictHostKeyChecking=no git@127.0.0.1 \"SSH_ORIGINAL_COMMAND=\\\"\$SSH_ORIGINAL_COMMAND\\\" \$0 \$@\"" | sudo tee /usr/local/bin/gitea > /dev/null
sudo chmod +x /usr/local/bin/gitea

# switch between http / https dev / prod
[[ $IS_PEGAZDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"
