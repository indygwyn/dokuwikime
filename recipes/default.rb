#
# Cookbook:: dokuwikime
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#
case node['platform']
when 'centos'
  pkgs = %w( httpd24 httpd24-mod_ssl )
  svcs = %w( httpd24-httpd )
  # install SCL repo - this must install before the pkgs so the repo is available
  package 'centos-release-scl'
  case node['platform_version'].split('.')[0]
  when '6'
    pkgs.concat(%w( rh-php70 rh-php70-php-cli rh-php70-php-fpm rh-php70-php-gd rh-php70-php-mbstring rh-php70-php-xml rh-php70-php-json ))
    svcs.concat(%w( rh-php70-php-fpm ))
  when '7'
    pkgs.concat(%w( rh-php72 rh-php72-php-cli rh-php72-php-fpm rh-php72-php-gd rh-php72-php-mbstring rh-php72-php-xml rh-php72-php-json ))
    svcs.concat(%w( rh-php72-php-fpm ))
  end
when 'ubuntu'
  pkgs = %w( apache2 php php-fpm php-gd php-mbstring php-xml )
  svcs = %w( apache2 )
  case node['platform_version'].split('.')[0]
  when '16'
    svcs.concat(%w( php7.0-fpm ))
  when '18'
    svcs.concat(%w( php7.2-fpm ))
  end
end

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

case node['platform']
when 'centos'
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
  # install the selinux policy mgmt tools
  include_recipe 'selinux_policy::install'
  # allow httpd to make network connections for updates and plugin install
  selinux_policy_boolean 'httpd_can_network_connect' do
    value true
    notifies :restart, 'service[httpd24-httpd]'
  end
  # allow httpd to use sendmail
  selinux_policy_boolean 'httpd_can_sendmail' do
    value true
    notifies :restart, 'service[httpd24-httpd]'
  end
  # set dokuwiki files to http rw label
  selinux_policy_fcontext '/opt/dokuwiki(/.*)?' do
    secontext 'httpd_sys_rw_content_t'
  end
when 'ubuntu'
  # Enable Apache actions module
  execute 'actions' do
    command '/usr/sbin/a2enmod actions'
  end
  # Enable Apache alias module
  execute 'alias' do
    command '/usr/sbin/a2enmod alias'
  end
  # Apache config to enable dokuwiki at /dokuwiki/
  template '/etc/apache2/conf-available/dokuwiki.conf' do
    source 'dokuwiki.conf.erb'
    mode '0644'
    owner 'root'
    group 'root'
  end
  # enable dokuwiki apache config
  execute 'dokuwiki' do
    command '/usr/sbin/a2enconf dokuwiki'
    notifies :restart, 'service[apache2]'
  end
  case node['platform_version'].split('.')[0]
  when '16'
    # install apache php and some php modules
    package 'libapache2-mod-fastcgi' do
      action :install
    end
    # enable php7.0-fpm apache config
    execute 'proxy_fcgi' do
      command '/usr/sbin/a2enmod proxy_fcgi'
      notifies :restart, 'service[apache2]'
    end
    # enable php7.0-fpm apache config
    execute 'php7.0-fpm' do
      command '/usr/sbin/a2enconf php7.0-fpm'
      notifies :restart, 'service[apache2]'
    end
  when '18'
    # enable php7.2-fpm apache config
    execute 'php7.2-fpm' do
      command '/usr/sbin/a2enconf php7.2-fpm'
      notifies :restart, 'service[apache2]'
    end
  end
  # Meta refresh to /dokuwiki/
  template '/var/www/html/index.html' do
    source 'index.html.erb'
    mode '0644'
    owner 'root'
    group 'root'
  end
end
# Use ark to download and install the dokuwiki stable release at /opt/dokuwiki
ark 'dokuwiki' do
  url 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz'
  path '/opt'
  owner node['apache']['user']
  group node['apache']['group']
  action :put
end
# Make a default start page that directs you to the install
template '/opt/dokuwiki/data/pages/start.txt' do
  source 'start.txt.erb'
  mode '0644'
  owner node['apache']['user']
  group node['apache']['group']
end
svcs.each do |svc|
  service svc do
    action [ :enable, :start ]
  end
end
