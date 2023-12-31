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
${BIN_DIR}/box cfconfig import from=${WWW_DIR}/www/conf/cfconfig/myconfig.json toFormat=adobe@2021

# setup alias in attempt to fix CGI.SCRIPT_NAME
# Currently:  /htdocs/admin/index.cfm
# Desired:    /admin/index.cfm
${BIN_DIR}/box server set web.aliases./admin=/virtual/local.com/www/htdocs/admin

# Start Apache
apache2ctl start

# Run finalized CommandBox startup script
${BIN_DIR}/startup-final.sh

exec "$@"


