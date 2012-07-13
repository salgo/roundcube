#
# Cookbook Name:: roundcube
# Recipe:: default
#
# Based on Wordpress cookbook
#
# Copyright 2009-2010, Opscode, Inc.
# Copyright 2012, Andy Gale
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "apache2"
include_recipe "mysql::server"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "apache2::mod_php5"

node.set['roundcube']['db']['password'] = secure_password

if node.has_key?("ec2")
  server_fqdn = node['ec2']['public_hostname']
else
  server_fqdn = node['fqdn']
end

remote_file "#{Chef::Config[:file_cache_path]}/roundcubemail-#{node['roundcube']['version']}.tar.gz" do
  checksum node['roundcube']['checksum']
  source "http://downloads.sourceforge.net/project/roundcubemail/roundcubemail/#{node['roundcube']['version']}/roundcubemail-#{node['roundcube']['version']}.tar.gz"
  mode "0644"
end

directory "#{node['roundcube']['dir']}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

execute "untar-roundcube" do
  cwd node['roundcube']['dir']
  command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/roundcubemail-#{node['roundcube']['version']}.tar.gz"
  creates "#{node['roundcube']['dir']}/robots.txt"
end

execute "mysql-install-roundcube-privileges" do
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" < #{node['mysql']['conf_dir']}/roundcube-grants.sql"
  action :nothing
end

template "#{node['mysql']['conf_dir']}/roundcube-grants.sql" do
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node['roundcube']['db']['user'],
    :password => node['roundcube']['db']['password'],
    :database => node['roundcube']['db']['database']
  )
  notifies :run, "execute[mysql-install-roundcube-privileges]", :immediately
end

execute "create #{node['roundcube']['db']['database']} database" do
  command "/usr/bin/mysqladmin -u root -p\"#{node['mysql']['server_root_password']}\" create #{node['roundcube']['db']['database']}"
  not_if do
    require 'mysql'
    m = Mysql.new("localhost", "root", node['mysql']['server_root_password'])
    m.list_dbs.include?(node['roundcube']['db']['database'])
  end
  notifies :create, "ruby_block[save node data]", :immediately unless Chef::Config[:solo]
end

# save node data after writing the MYSQL root password, so that a failed chef-client run that gets this far doesn't cause an unknown password to get applied to the box without being saved in the node data.
unless Chef::Config[:solo]
  ruby_block "save node data" do
    block do
      node.save
    end
    action :create
  end
end

execute "mysql-install-roundcube-db" do
  command "/usr/bin/mysql -u #{node['roundcube']['db']['user']} -p\"#{node['roundcube']['db']['password']}\" #{node['roundcube']['db']['database']} < #{node['roundcube']['dir']}/SQL/mysql.initial.sql"
  not_if do
    require 'mysql'
    m = Mysql.new("localhost", node['roundcube']['db']['user'],
                  node['roundcube']['db']['password'],
                  node['roundcube']['db']['database'])
    m.list_tables.include?('session')
  end
end

template "#{node['roundcube']['dir']}/config/db.inc.php" do
  source "db.inc.php.erb"
  owner "www-data"
  group "www-data"
  mode "0644"
  variables(
    :database        => node['roundcube']['db']['database'],
    :user            => node['roundcube']['db']['user'],
    :password        => node['roundcube']['db']['password']
  )
end

template "#{node['roundcube']['dir']}/config/main.inc.php" do
  source "main.inc.php.erb"
  owner "www-data"
  group "www-data"
  mode "0644"
  variables(
    :imap_default_host => node['roundcube']['imap_default_host'],
    :imap_default_port => node['roundcube']['imap_default_port'],
    :smtp_default_host => node['roundcube']['smtp_default_host'],
    :smtp_default_port => node['roundcube']['smtp_default_port'],
    :smtp_default_user => node['roundcube']['smtp_default_user'],
    :smtp_default_pass => node['roundcube']['smtp_default_pass'],
    :smtp_auth_type => node['roundcube']['smtp_auth_type'])
end

apache_site "000-default" do
  enable false
end

web_app "roundcube" do
  template "roundcube.conf.erb"
  docroot "#{node['roundcube']['dir']}"
  server_name "#{node['roundcube']['host']}"
  server_aliases node['roundcube']['server_aliases']
end