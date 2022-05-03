#!/bin/sh
# Should be set to the public domain where penpot is going to be served.
PENPOT_PUBLIC_URI=http://localhost:9001

# Temporal workaround because of bad builtin default
PENPOT_HTTP_SERVER_HOST=0.0.0.0

# Standard database connection parameters (only postgresql is supported):
PENPOT_DATABASE_URI=postgresql://penpot-postgres/penpot
PENPOT_DATABASE_USERNAME=penpot
PENPOT_DATABASE_PASSWORD=penpot

# Redis is used for the websockets notifications.
PENPOT_REDIS_URI=redis://penpot-redis/0

# By default, files uploaded by users are stored in local filesystem. But it
# can be configured to store in AWS S3 or completely in de the database.
# Storing in the database makes the backups more easy but will make access to
# media less performant.
ASSETS_STORAGE_BACKEND=assets-fs
PENPOT_STORAGE_ASSETS_FS_DIRECTORY=/opt/data/assets

# Telemetry. When enabled, a periodical process will send anonymous data about
# this instance. Telemetry data will enable us to learn on how the application
# is used, based on real scenarios. If you want to help us, please leave it
# enabled.
PENPOT_TELEMETRY_ENABLED=true

# Email sending configuration. By default, emails are printed in the console,
# but for production usage is recommended to setup a real SMTP provider. Emails
# are used to confirm user registrations.
PENPOT_SMTP_ENABLED=false
PENPOT_SMTP_DEFAULT_FROM=no-reply@example.com
PENPOT_SMTP_DEFAULT_REPLY_TO=no-reply@example.com
# PENPOT_SMTP_HOST=
# PENPOT_SMTP_PORT=
# PENPOT_SMTP_USERNAME=
# PENPOT_SMTP_PASSWORD=
# PENPOT_SMTP_TLS=true
# PENPOT_SMTP_SSL=false

# Feature flags. Right now they are only affect frontend, but in
# future release they will affect to both backend and frontend.
PENPOT_FLAGS="enable-registration enable-demo-users"

# Comma separated list of allowed domains to register. Empty to allow all.
# PENPOT_REGISTRATION_DOMAIN_WHITELIST=""

## Authentication providers

# Google
# PENPOT_GOOGLE_CLIENT_ID=
# PENPOT_GOOGLE_CLIENT_SECRET=

# GitHub
# PENPOT_GITHUB_CLIENT_ID=
# PENPOT_GITHUB_CLIENT_SECRET=

# GitLab
# PENPOT_GITLAB_BASE_URI=https://gitlab.com
# PENPOT_GITLAB_CLIENT_ID=
# PENPOT_GITLAB_CLIENT_SECRET=

# OpenID Connect (since 1.5.0)
# PENPOT_OIDC_BASE_URI=
# PENPOT_OIDC_CLIENT_ID=
# PENPOT_OIDC_CLIENT_SECRET=

# LDAP
# PENPOT_LDAP_HOST=ldap
# PENPOT_LDAP_PORT=10389
# PENPOT_LDAP_SSL=false
# PENPOT_LDAP_STARTTLS=false
# PENPOT_LDAP_BASE_DN=ou=people,dc=planetexpress,dc=com
# PENPOT_LDAP_BIND_DN=cn=admin,dc=planetexpress,dc=com
# PENPOT_LDAP_BIND_PASSWORD=GoodNewsEveryone
# PENPOT_LDAP_ATTRS_USERNAME=uid
# PENPOT_LDAP_ATTRS_EMAIL=mail
# PENPOT_LDAP_ATTRS_FULLNAME=cn
# PENPOT_LDAP_ATTRS_PHOTO=jpegPhoto
# PENPOT_LOGIN_WITH_LDAP=true

