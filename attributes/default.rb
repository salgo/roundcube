default['roundcube']['version'] = "0.7.2"
default['roundcube']['checksum'] = "a29e4aded3a3b01b763e60443f5afb4cb2969365532762f4436793e8b98cea17"
default['roundcube']['dir'] = '/var/www/roundcube'
default['roundcube']['db']['database'] = "roundcubedb"
default['roundcube']['db']['user'] = "roundcubeuser"
default['roundcube']['server_aliases'] = [node['fqdn']]
default['roundcube']['imap_default_host'] = ''
default['roundcube']['imap_default_port'] = 143
default['roundcube']['smtp_default_host'] = 'localhost'
default['roundcube']['smtp_default_port'] = 25
default['roundcube']['smtp_default_user'] = '%u'
default['roundcube']['smtp_default_pass'] = '%p'
default['roundcube']['smtp_auth_type'] = ''