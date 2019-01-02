# # encoding: utf-8

# Inspec test for recipe dokuwikime::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe yum.repo('centos-sclo-rh') do 
  it { should be_enabled }
end

%w(centos-release-scl httpd24 rh-php72-php-fpm).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe directory('/opt/dokuwiki') do
  it { should exist }
end

%w(/opt/rh/httpd24/root/etc/httpd/conf.d/dokuwiki.conf /opt/rh/httpd24/root/etc/httpd/conf.d/php-fpm.conf).each do |fp|
  describe file(fp) do
    it { should exist }
  end
end

%w(httpd24-httpd rh-php72-php-fpm).each do |svc|
  describe service(svc) do
    it { should be_running }
  end
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
