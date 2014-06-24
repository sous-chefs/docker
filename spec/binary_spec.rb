require 'spec_helper'

describe 'docker::binary' do

  context 'by default' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.automatic['kernel']['release'] = "3.8.0"
      end.converge(described_recipe)
    end

    it 'downloads docker binary' do
      expect(chef_run).to create_remote_file_if_missing('/usr/bin/docker')
    end

    it 'includes iptables cookbook' do
      expect(chef_run).to include_recipe('iptables')
    end
    
    it 'includes git cookbook' do
      expect(chef_run).to include_recipe('git')
    end

    it 'installs procps package' do
      expect(chef_run).to install_package('procps')
    end

    it 'installs the XZ Utilities package' do
      deb_run = ChefSpec::Runner.new(platform: 'ubuntu', version: '14.04').converge(described_recipe)
      rhel_run = ChefSpec::Runner.new(platform: 'redhat', version: '6.5') do |node|
        node.automatic['kernel']['release'] = '3.8.0'
      end.converge(described_recipe)

      expect(deb_run).to install_package('xz-utils')
      expect(rhel_run).to install_package('xz')
    end

    it 'setup cgroupfs mount' do
      expect(chef_run).to run_bash('cgroupfs-mount')
    end
  end

  context 'running on a RHEL machine running Linux Kernel < 3.8' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'redhat', version: '6.5') do |node|
        node.automatic['kernel']['release'] = '2.6.32-431'
      end.converge(described_recipe)
    end

    it 'should fail with a helpful, RHEL-specific error message' do
      expect { chef_run }.to raise_error(DockerCookbook::Exceptions::InvalidKernelVersion)
    end
  end

  context 'when install_dir is set' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.normal['docker']['install_dir'] = '/tmp'
        node.automatic['kernel']['release'] = "3.8.0"
      end.converge(described_recipe)
    end

    it 'downloads docker binary to install_dir' do
      expect(chef_run).to create_remote_file_if_missing('/tmp/docker')
    end
  end

  context 'when install_type is binary' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
        node.normal['docker']['install_type'] = 'binary'
        node.automatic['kernel']['release'] = "3.8.0"
      end.converge(described_recipe)
    end

    it 'downloads docker binary to install_dir' do
      expect(chef_run).to create_remote_file_if_missing('/usr/local/bin/docker')
    end
  end
end
