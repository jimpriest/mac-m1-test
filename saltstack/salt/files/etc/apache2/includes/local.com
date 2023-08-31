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

Alias /admin /virtual/local.com/www/htdocs/admin
Alias /CFIDE /usr/local/lib/serverHome/CFIDE

<Location />
	Options -Indexes
</Location>

<Location /admin/reports/>
	Options +Indexes
</Location>

<Directory /virtual/local.com/www/htdocs>
    Options +Indexes +FollowSymLinks
    AllowOverride all
    Require all granted
    DirectoryIndex index.cfm
</Directory>

<Directory /usr/local/lib/serverHome/CFIDE>
    Options +Indexes +FollowSymLinks
    AllowOverride all
    Require all granted
</Directory>