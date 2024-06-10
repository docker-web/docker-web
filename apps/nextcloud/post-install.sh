#!/bin/bash

OCC() {
  docker exec -u www-data nextcloud php occ $1
}

# install apps
for APP in $APPS_PRE_INSTALLED
do
    OCC "app:install $APP"
done

# enable apps
for APP in $APPS_ENABLED
do
    OCC "app:enable $APP"
done

# disable apps
for APP in $APPS_DISABLED
do
    OCC "app:disable $APP"
done

# Settings
OCC "user:setting $USERNAME settings email $EMAIL"
CONF_FILENAME="/tmp/external_conf.json"
cat > $CONF_FILENAME <<EOF
{
  "mount_id": 1,
  "mount_point": "\/",
  "storage": "\\\\OC\\\\Files\\\\Storage\\\\Local",
  "authentication_type": "null::null",
  "configuration": {
    "datadir": "\/mnt\/media"
  },
  "options": {
    "enable_sharing": true,
    "encoding_compatibility": false,
    "encrypt": true,
    "filesystem_check_changes": 1,
    "previews": true,
    "readonly": false
  },
  "applicable_users": [
    "$USERNAME"
  ],
  "applicable_groups": [
    "admin"
  ]
}
EOF
docker cp $CONF_FILENAME nextcloud:$CONF_FILENAME
OCC "files_external:import $CONF_FILENAME"
rm $CONF_FILENAME
