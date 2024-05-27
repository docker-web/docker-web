#!/bin/bash
# SSH Container Passthrough
sudo useradd git >/dev/null 2>&1
sudo chown -R git:git /home/git/
sudo -u git touch /home/git/.ssh/id_rsa
sudo -u git chmod 600 /home/git/.ssh/id_rsa
sudo -u git chown -R git:git /home/git/
sudo -u git ssh-keygen -q -t rsa -b 4096 -C "Gitea Host Key" -N "" -f /home/git/.ssh/id_rsa <<<y > /dev/null
sudo -u git cat /home/git/.ssh/id_rsa.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys > /dev/null
sudo echo -e "#!/bin/bash
ssh -p ${PORT_SSH} -o StrictHostKeyChecking=no git@127.0.0.1 \"SSH_ORIGINAL_COMMAND=\\\"\$SSH_ORIGINAL_COMMAND\\\" \$0 \$@\"" | sudo tee /usr/local/bin/gitea > /dev/null
sudo chmod +x /usr/local/bin/gitea
docker exec -u root gitea chown -R git:git /data/git/.ssh
