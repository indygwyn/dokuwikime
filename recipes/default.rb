#
# Cookbook:: dokuwikime
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#

case node['platform']
# centos common stuff
when 'centos'
  # install SCL repo
  package 'centos-release-scl'
  # install apache24
  package %w( httpd24 httpd24-mod_ssl ) do
    action :install
      only_if "yum repolist enabled | grep centos-sclo"
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
  case node['platform_version'].split('.')[0]
  # centos 6 specfic stuff
  when '6'
    # install php70 and some modules
    package %w( rh-php70 rh-php70-php-cli rh-php70-php-fpm rh-php70-php-gd rh-php70-php-mbstring rh-php70-php-xml rh-php70-php-json ) do
      action :install
    end
    # enable and start PHP FPM
    service 'rh-php70-php-fpm' do
      action [ :enable, :start ]
    end
  # centos 7 specfic stuff
  when '7'
    # install php72 and some modules
    package %w( rh-php72 rh-php72-php-cli rh-php72-php-fpm rh-php72-php-gd rh-php72-php-mbstring rh-php72-php-xml rh-php72-php-json ) do
      action :install
    end
    # enable and start PHP FPM
    service 'rh-php72-php-fpm' do
      action [ :enable, :start ]
    end
  end
  # install the selinux policy mgmt tools
  include_recipe 'selinux_policy::install'
  # allow httpd to make network connections for updates and plugin install
  selinux_policy_boolean 'httpd_can_network_connect' do
   value true
   notifies :restart,'service[httpd24-httpd]'
  end
  # allow httpd to use sendmail
  selinux_policy_boolean 'httpd_can_sendmail' do
    value true
    notifies :restart,'service[httpd24-httpd]'
  end
  # set dokuwiki files to http rw label
  selinux_policy_fcontext '/opt/dokuwiki(/.*)?' do
    secontext 'httpd_sys_rw_content_t'
  end
  # enable and start httpd24
  service 'httpd24-httpd' do
    action [ :enable, :start ]
  end
# Ubuntu stuff
when 'ubuntu'
  # install apache php and some php modules
  package %w( apache2 php php-fpm php-gd php-mbstring php-xml ) do
    action :install
  end
  # Enable Apache actions module
  execute 'actions' do
    command "/usr/sbin/a2enmod actions"
  end 
  # Enable Apache alias module
  execute 'alias' do 
    command "/usr/sbin/a2enmod alias"
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
  # version specific stuff
  case node['platform_version'].split('.')[0]
  # ubuntu 16 stuff
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
    # enable and start PHP FPM 
    service 'php7.0-fpm' do
      action [ :enable, :start ]
    end
  # ubuntu 18 stuff
  when '18'
    # enable php7.2-fpm apache config
    execute 'php7.2-fpm' do
      command '/usr/sbin/a2enconf php7.2-fpm'
      notifies :restart, 'service[apache2]'
    end 
    # enable and start PHP FPM 
    service 'php7.2-fpm' do
      action [ :enable, :start ]
    end
  end
  # Meta refresh to /dokuwiki/
  template '/var/www/html/index.html' do
    source 'index.html.erb'
    mode '0644'
    owner 'root'
    group 'root'
  end
  # enable and start Apache
  service 'apache2' do
    action [ :enable, :start ]
  end
end
#COMMON STUFF
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
