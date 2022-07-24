#!/bin/bash

# gitea pre install only on root !
[[ ${EUID} -ne 0 ]] && printf "[x] up gitea must be run as root.'\n" && exit

useradd git
chown -R git:git /home/git/

# SSH Container Passthrough
-u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key" -N "" -f "/home/git/.ssh/id_rsa" -y > /dev/null
-u git cat /home/git/.ssh/id_rsa.pub | -u git tee -a /home/git/.ssh/authorized_keys > /dev/null
-u git chmod 750 /home/git/.ssh/authorized_keys
echo -e "#!/bin/bash
ssh -p ${PORT_SSH} -o StrictHostKeyChecking=no git@127.0.0.1 \"SSH_ORIGINAL_COMMAND=\\\"\$SSH_ORIGINAL_COMMAND\\\" \$0 \$@\"" | tee /usr/local/bin/gitea > /dev/null
chmod +x /usr/local/bin/gitea

# switch between http / https dev / prod
[[ $IS_PEGAZDEV == "false" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_PEGAZ_SERVICES/$1/config.sh"

# drone config
DRONE_RPC_SECRET=$(openssl rand -hex 16)
sed -i "s/DRONE_RPC_SECRET=.*/DRONE_RPC_SECRET=\"$DRONE_RPC_SECRET\"/" "$PATH_PEGAZ_SERVICES/$1/config.sh"
