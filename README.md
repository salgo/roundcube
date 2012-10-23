
Description
===========

Downloads, installs and configures Roundcube, a web base email system. Exposes various configuration options as attributes.

Requirements
============

Platform
--------

Debian, Ubuntu.

Tested on: 

- Debian 6 (Squeeze)

Cookbooks
---------

- mysql
- php
- apache2
- opensssl (uses library to generate secure passwords)

Attributes
==========

- node['roundcube']['version'] - defaults to 0.7.2 which is currently the latest and matches the checksum
- node['roundcube']['checksum'] - used to confirm downloaded source is correct, default matches 0.7.2
- node['roundcube']['dir'] - directory to install files to and use as doucment root, default /var/www/roundcube
- node['roundcube']['db']['database'] - database name to use, default 'roundcubedb'
- node['roundcube']['db']['user'] - database username, default 'roundcubeuser'
- node['roundcube']['server_aliases'] - array, other server aliases for virtualhost

### imap_default_host

node['roundcube']['imap_default_host'] - default host is empty (which allows the user to enter one on sign in)

To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://
Supported replacement variables:
 %n - http hostname ($_SERVER['SERVER_NAME'])
 %d - domain (http hostname without the first part)
 %s - domain name after the '@' from e-mail address provided at login screen
 For example %n = mail.domain.tld, %d = domain.tld

- node['roundcube']['imap_default_port'] - default port is 143, the default IMAP port
- node['roundcube']['smtp_default_host'] - SMTP host, default is 'localhost'

To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://

If left blank, the PHP mail() function is used

Supported replacement variables:
%h - user's IMAP hostname
%n - http hostname ($_SERVER['SERVER_NAME'])
%d - domain (http hostname without the first part)
%z - IMAP domain (IMAP hostname without the first part)

For example %n = mail.domain.tld, %d = domain.tld

- node['roundcube']['smtp_default_port'] - SMTP port, default is 25
- node['roundcube']['smtp_default_user'] - SMTP username, default is '%u' which in Roundcube configuration means the username supplied at login (i.e. the IMAP one)
- node['roundcube']['smtp_default_pass'] - SMTP password, default is '%p' which in Roundcube configuration means the password supplied at login (i.e. the IMAP one)
- node['roundcube']['smtp_auth_type'] - SMTP auth type default is '' which means auto-detect 
