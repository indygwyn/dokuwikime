# # encoding: utf-8

# Inspec test for recipe dokuwikime::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/


describe package('centos-release-scl') do
	it { should be_installed }
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

describe port(80) do
  it { should be_listening }
end

describe command('curl http://localhost/dokuwiki/') do
	its('stdout') { should match /dokuwiki/ }
end
