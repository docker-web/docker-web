#!/bin/bash
export SUBDOMAIN="penpot"
export PORT="7707"
export PORT_EXPOSED="80"
export PORT_DB="7708"
export PENPOT_FLAGS="enable-registration disable-secure-session-cookies"
export POST_INSTALL_TEST_CMD="docker exec penpot-backend ./manage.sh"
