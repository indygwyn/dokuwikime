#
# Cookbook:: dokuwikime
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'spec_helper'

shared_examples 'dokuwikime' do |platform, version, packages, services|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: platform, version: version)
      runner.converge(described_recipe)
    end
    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
    packages.each do |package|
      it "installs #{package}" do
        expect(chef_run).to install_package package
      end
    end
    services.each do |service|
      it "enables the #{service} service" do
        expect(chef_run).to enable_service service
      end
    end
    services.each do |service|
      it "starts the #{service} service" do
        expect(chef_run).to start_service service
      end
    end
  end
end

describe 'dokuwikime::default' do
  platforms = {
    'centos69' => ['6.9',
                   ['httpd24', 'httpd24-mod_ssl', 'rh-php70', 'rh-php70-php-fpm', 'rh-php70-php-gd', 'rh-php70-php-mbstring', 'rh-php70-php-xml', 'rh-php70-php-json'],
                   ['httpd24-httpd', 'rh-php70-php-fpm']],
    'centos76' => ['7.6.1804',
                   ['httpd24', 'httpd24-mod_ssl', 'rh-php72', 'rh-php72-php-fpm', 'rh-php72-php-gd', 'rh-php72-php-mbstring', 'rh-php72-php-xml', 'rh-php72-php-json'],
                   ['httpd24-httpd', 'rh-php72-php-fpm']],
    'ubuntu16' => ['16.04',
                   ['apache2', 'php', 'php-fpm', 'php-gd', 'php-mbstring', 'php-xml'],
                   ['apache2', 'php7.0-fpm']],
    'ubuntu18' => ['18.04',
                   ['apache2', 'php', 'php-fpm', 'php-gd', 'php-mbstring', 'php-xml'],
                   ['apache2', 'php7.2-fpm']],
  }
  platforms.each do |platform, platform_data|
    include_examples 'dokuwikime', platform[0, 6], *platform_data
  end
end
