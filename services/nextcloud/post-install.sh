
OCC() {
  if [ "$(id -u)" = 0 ]; then
    su -p www-data -s /bin/sh -c "php /var/www/html/occ $1 || echo '$1 failed'"
  else
    sh -c "$1"
  fi
}

# install apps
for APP in $NEXTCLOUD_APPS_INSTALL
do
    echo "installing: $APP"
    OCC "app:install $APP"
    OCC "app:enable $APP"
done

# disable apps
for APP in $NEXTCLOUD_APPS_DISABLE
do
    OCC "app:disable $APP"
done

# Settings
#OCC "user:setting $NEXTCLOUD_ADMIN_USER settings email 'bofh@mailserver.guru'"
# OCC "config:system:set datadirectory --value=$DATA_DIR"
# Check if remote share needs to be configured
# if [ "No admin mounts configured" = "$(run_as 'php /var/www/html/occ files_external:list')" ]; then
#   echo "Configure remote homes for FUSS Server"
#   cat > /tmp/fe_conf.txt <<EOF
# {
#     "mount_id": 3,
#     "mount_point": "\/",
#     "storage": "\\\\OCA\\\\Files_External\\\\Lib\\\\Storage\\\\SMB",
#     "authentication_type": "password::logincredentials",
#     "configuration": {
#         "host": "${FUSS_SERVER_FQDN}",
#         "share": "homes",
#         "root": "",
#         "domain": "",
#         "show_hidden": false
#     },
#     "options": {
#         "enable_sharing": true
#     },
#     "applicable_users": [],
#     "applicable_groups": [
#         "${FUSS_AUTHORIZED_GROUP}"
#     ]
# }
# EOF
#   run_as "php /var/www/html/occ files_external:import /tmp/fe_conf.txt"
#   rm /tmp/fe_conf.txt
# fi
