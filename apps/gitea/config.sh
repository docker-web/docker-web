
#!/bin/bash
export DOMAIN="git.$MAIN_DOMAIN"
export PORT="7722"
export PORT_EXPOSED="3000"
export PORT_SSH="7724"
export PORT_SSH_EXPOSED="22"
export PORT_DB="7723"
export POST_INSTALL_TEST_CMD="docker exec gitea gitea admin"
export PROTO="https"
export REDIRECTIONS=""
