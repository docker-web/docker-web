#!/bin/bash
cat <<"EOF" | sudo tee /usr/local/bin/gitea
#!/bin/sh
ssh -p $GIT_SSH_PORT -o StrictHostKeyChecking=no git@127.0.0.1 \
"SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
EOF
sudo chmod +x /usr/local/bin/gitea

sudo useradd git
GIT_UID=$(id -u git)
GIT_GID=$(id -g git)

sudo su git -c ssh-add-key git@localhost -p $PORT_SSH
