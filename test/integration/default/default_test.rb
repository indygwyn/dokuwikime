# # encoding: utf-8

# Inspec test for recipe dokuwikime::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

case os[:name]
when 'centos'
  apacheuser = 'apache'
  pkgs = %w( centos-release-scl httpd24 httpd24-mod_ssl )
  svcs = %w( httpd24-httpd )

  describe yum.repo('centos-sclo-rh') do
    it { should be_enabled }
  end

  %w(/opt/rh/httpd24/root/etc/httpd/conf.d/dokuwiki.conf /opt/rh/httpd24/root/etc/httpd/conf.d/php-fpm.conf).each do |fp|
    describe file(fp) do
      it { should exist }
    end
  end

  case os[:release].split('.')[0]
  when '6'
    pkgs.concat(%w( rh-php70 rh-php70-php-cli rh-php70-php-fpm rh-php70-php-gd rh-php70-php-mbstring rh-php70-php-xml rh-php70-php-json ))
    svcs.concat(%w( rh-php70-php-fpm ))
  when '7'
    pkgs.concat(%w( rh-php72 rh-php72-php-cli rh-php72-php-fpm rh-php72-php-gd rh-php72-php-mbstring rh-php72-php-xml rh-php72-php-json ))
    svcs.concat(%w( rh-php72-php-fpm ))
  end

when 'ubuntu'
  apacheuser = 'www-data'
  pkgs = %w( apache2 php php-fpm php-gd php-mbstring php-xml )
  svcs = %w( apache2 )
  case os[:release].split('.')[0]
  when '16'
    svcs.concat(%w( php7.0-fpm ))
  when '18'
    svcs.concat(%w( php7.2-fpm ))
  end

end

pkgs.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

svcs.each do |svc|
  describe service(svc) do
    it { should be_running }
  end
end

describe directory('/opt/dokuwiki') do
  it { should exist }
end

describe file('/opt/dokuwiki/data/pages/start.txt') do
  it { should exist }
  its('owner') { should eq apacheuser }
  its('mode') { should cmp '0644' }
end

describe port(80) do
  it { should be_listening }
end

# describe http('http://localhost/dokuwiki/') do
#  its('status') { should cmp 200 }
#  its('body') { should match /start\.txt/ }
#  its('headers.Content-Type') { should match /text\/html/ }
# end
