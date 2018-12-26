#
# Cookbook:: dokuwikime
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

package 'centos-release-scl'

package %w{ httpd24 httpd24-mod_ssl rh-php72 rh-php72-php-cli rh-php72-php-fpm rh-php72-php-gd rh-php72-php-mbstring rh-php72-php-xml rh-php72-php-json }

ark 'dokuwiki' do
	url 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz'
	path '/opt'
	owner 'apache'
	group 'apache'
	action :put
end

template '/opt/rh/httpd24/root/etc/httpd/conf.d/dokuwiki.conf' do
	source 'dokuwiki.conf.erb'
	mode '0644'
	owner 'root'
	group 'root'
end

template '/opt/rh/httpd24/root/etc/httpd/conf.d/php-fpm.conf' do
	source 'php-fpm.conf.erb'
	mode '0644'
	owner 'root'
	group 'root'
end

service 'rh-php72-php-fpm' do
	action [ :enable, :start ]
end

service 'httpd24-httpd' do
	action [ :enable, :start ]
end
