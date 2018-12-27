#
# Cookbook:: dokuwikime
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

# Make the SCL repo avaialble
package 'centos-release-scl' do
  notifies :run, 'package[centos-release-scl]', :immediately
end

# All these packages depend on the SCL repo
package %w( httpd24 httpd24-mod_ssl rh-php72 rh-php72-php-cli rh-php72-php-fpm rh-php72-php-gd rh-php72-php-mbstring rh-php72-php-xml rh-php72-php-json ) do
  action :install
    only_if "yum repolist enabled | grep centos-sclo"
end

# Use ark to download and install the dokuwiki stable release at /opt/dokuwiki
ark 'dokuwiki' do
  url 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz'
  path '/opt'
  owner 'apache'
  group 'apache'
  action :put
end

# Apache config to enable dokuwiki at /dokuwiki/
template '/opt/rh/httpd24/root/etc/httpd/conf.d/dokuwiki.conf' do
  source 'dokuwiki.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[httpd24-httpd]'
end

# Apache config to enable PHP-FPM
template '/opt/rh/httpd24/root/etc/httpd/conf.d/php-fpm.conf' do
  source 'php-fpm.conf.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[httpd24-httpd]'
end

# Meta refresh to /dokuwiki/
template '/opt/rh/httpd24/root/var/www/html/index.html' do
  source 'index.html.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

# 
service 'rh-php72-php-fpm' do
  action [ :enable, :start ]
end

service 'httpd24-httpd' do
  action [ :enable, :start ]
end

