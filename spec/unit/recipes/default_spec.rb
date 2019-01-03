#
# Cookbook:: dokuwikime
# Spec:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'spec_helper'

shared_examples 'dokuwikime' do |platform, version, package, service|
  context "when run on #{platform} #{version}" do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: platform, version: version)
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it "installs #{package}" do
      expect(chef_run).to install_package package
    end

    it "enables the #{service} service" do
      expect(chef_run).to enable_service service
    end

    it "starts the #{service} service" do
      expect(chef_run).to start_service service
    end
  end
end

describe 'dokuwikime::default' do
  platforms = {
    'centos69' => ['centos','6.9', 'httpd24', 'httpd24-httpd'],
    'centos76' => ['centos','7.6.1804', 'httpd24', 'httpd24-httpd'],
    'ubuntu14' => ['ubuntu','14.04', 'apache2', 'apache2'],
    'ubuntu18' => ['ubuntu','18.04', 'apache2', 'apache2']
  }

  platforms.each do |platform, platform_data|
    include_examples 'dokuwikime', *platform_data
  end
end
