case node['platform']
when 'centos'
  default['apache']['user'] = 'apache'
  default['apache']['group'] = 'apache'
when 'ubuntu'
  default['apache']['user'] = 'www-data'
  default['apache']['group'] = 'www-data'
end
