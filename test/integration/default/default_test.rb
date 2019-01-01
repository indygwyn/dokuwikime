# # encoding: utf-8

# Inspec test for recipe dokuwikime::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('centos-release-scl') do
  it { should be_installed }
end

describe yum.repo('centos-sclo-rh') do 
  it { should be_enabled }
end

describe package('httpd24') do
  it { should be_installed }
end

describe package('rh-php72-php-fpm') do
  it { should be_installed }
end

describe directory('/opt/dokuwiki') do
  it { should exist }
end

describe file('/opt/rh/httpd24/root/etc/httpd/conf.d/dokuwiki.conf') do
  it { should exist }
end

describe file('/opt/rh/httpd24/root/etc/httpd/conf.d/php-fpm.conf') do
  it { should exist }
end

describe service('rh-php72-php-fpm') do
  it { should be_running }
end

describe service('httpd24-httpd') do
  it { should be_running }
end

describe file('/opt/dokuwiki/data/pages/start.txt') do
  it { should exist }
  its('owner') { should eq 'apache' }
  its('mode') { should cmp '0644' }
end

describe port(80) do
  it { should be_listening }
end

describe http('http://localhost/dokuwiki/') do
  its('status') { should cmp 200 }
  its('body') { should match /start\.txt/ }
  its('headers.Content-Type') { should match /text\/html/ }
end
