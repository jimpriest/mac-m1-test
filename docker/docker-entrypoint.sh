#! /usr/bin/env bash

set -e

# set paths that need auth
locations=(
  '/virtual/local.com/www/htdocs/admin/.htpasswd'
)

# Create the .htpasswd files
for location in ${locations[@]}; do
    htpasswd -cbs "${location}" admin admin
done


# Configure server with CFConfig (must have necessary cfpm packages installed before configuring server!)
${BIN_DIR}/box cfconfig import from=${APP_DIR}/conf/cfconfig/myconfig.json toFormat=adobe@2021

# Start Apache
apache2ctl start

# Run finalized CommandBox startup script
${BIN_DIR}/startup-final.sh

exec "$@"


