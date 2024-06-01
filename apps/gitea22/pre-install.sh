#!/bin/bash

# SSH Container Passthrough
sudo useradd git >/dev/null 2>&1
sudo chown -R git:git /home/git/

sudo touch /usr/local/bin/gitea-shell
sudo chmod +x /usr/local/bin/gitea-shell
sudo usermod -s /usr/local/bin/gitea-shell git

sudo tee -a /usr/local/bin/gitea-shell > /dev/null <<EOT
#!/bin/sh
/usr/bin/docker exec -i --env SSH_ORIGINAL_COMMAND="$SSH_ORIGINAL_COMMAND" gitea sh "$@"
EOT

sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOT
Match User git
  AuthorizedKeysCommandUser git
  AuthorizedKeysCommand /usr/bin/docker exec -i gitea /usr/local/bin/gitea keys -c /etc/gitea/app.ini -e git -u %u -t %t -k %k
EOT

/etc/init.d/ssh restart

# switch between http / https dev / prod
[[ $MAIN_DOMAIN != "domain.local" ]] && sed -i "s|PROTO=.*|PROTO=\"https\"|g" "$PATH_DOCKERWEB_APPS/$1/config.sh"
