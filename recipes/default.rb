#
# Cookbook:: dokuwikime
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

# Make the SCL repo avaialble
package 'centos-release-scl' 

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

include_recipe 'selinux_policy::install'

selinux_policy_boolean 'httpd_can_network_connect' do
  value true
  notifies :start,'service[httpd24-httpd]', :immediate
  notifies :start,'service[rh-php72-php-fpm]', :immediate
end

selinux_policy_boolean 'httpd_can_sendmail' do
	value true
end

selinux_policy_fcontext '/opt/dokuwiki(/.*)?' do
  secontext 'httpd_sys_rw_content_t'
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

# Make a default start page that directs you to the install
template '/opt/dokuwiki/data/pages/start.txt' do
  source 'start.txt.erb'
  mode '0644'
  owner 'apache'
  group 'apache'
end

# enable and start PHP FPM
service 'rh-php72-php-fpm' do
  action [ :enable, :start ]
end

# enable and start httpd24
service 'httpd24-httpd' do
  action [ :enable, :start ]
end

