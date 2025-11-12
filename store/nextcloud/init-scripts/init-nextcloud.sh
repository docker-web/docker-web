#!/bin/bash
set -e

# -----------------------------
# Nextcloud initialization script
# -----------------------------
# This script enables/disables predefined apps and mounts /mnt/media as external storage.
# Existing files in /mnt/media will not be deleted.
# -----------------------------

# Define apps
APPS_PRE_INSTALLED="calendar contacts mail notes"
APPS_ENABLED="files_external"
APPS_DISABLED="activity dashboard recommendations photos"

# Enable preinstalled apps
for app in $APPS_PRE_INSTALLED; do
  echo "➡ Enabling preinstalled app: $app"
  php occ app:enable "$app" || true
done

# Enable additional apps
for app in $APPS_ENABLED; do
  echo "➡ Enabling additional app: $app"
  php occ app:enable "$app" || true
done

# Disable apps
for app in $APPS_DISABLED; do
  echo "➡ Disabling app: $app"
  php occ app:disable "$app" || true
done

# Create external storage for /mnt/media
STORAGE_NAME="Media"
EXISTS=$(php occ files_external:list | grep -w "$STORAGE_NAME" || true)
if [ -z "$EXISTS" ]; then
  echo "➡ Creating external storage $STORAGE_NAME -> /mnt/media"
  php occ files_external:create "/" local null::null -c datadir="/mnt/media"
else
  echo "✔ External storage $STORAGE_NAME already exists"
fi

echo "✅ Nextcloud initialization completed"
