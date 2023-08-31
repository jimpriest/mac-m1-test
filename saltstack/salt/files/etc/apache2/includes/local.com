# this should be used for the default vhost
# Note: to prevent or allow directory browsing set BOX_SERVER_PROFILE appropriately in Dockerfile (see comments there)

ServerName local.com
ServerAlias local.local
LogLevel alert rewrite:trace3

# Point to main Apache dir for default webroot
DocumentRoot /var/www/html

ServerSignature Email
ServerAdmin service@local.com
ErrorLog /virtual/local.com/logs/apache_error.log
CustomLog /virtual/local.com/logs/apache_access.log "combined"


# PROXY SETTINGS
# If you comment these out - htaccess basic auth will work correctly
# With proxy enabled however you are not prompted for username/password

ProxyRequests       Off
ProxyPreserveHost   Off

<Location /admin>
    AuthType Basic
    AuthUserFile /virtual/local.com/www/htdocs/admin/.htpasswd
    AuthGroupFile /dev/null
    AuthName "Admin"
    require valid-user

    ProxyPass           http://localhost:8080/htdocs/admin/
    ProxyPassReverse    http://localhost:8080/htdocs/admin/
</Location>

ProxyPass           /CFIDE http://localhost:8080/CFIDE/
ProxyPassReverse    /CFIDE http://localhost:8080/CFIDE/


