require 'spec_helper'
require_relative 'support/matchers'

describe 'docker::default' do
  before(:each) do
    # TODO: Add to aufs cookbook
    shellout = double
    apt_cache = double('apt-cache')
    uname = double

    Mixlib::ShellOut.stub(:new).and_return(shellout)
    allow(shellout).to receive(:run_command).and_return(apt_cache)
    allow(apt_cache).to receive(:stdout).and_return('linux-image-extra-3.')
    allow(shellout).to receive(:run_command).and_return(uname)
    allow(uname).to receive(:stdout).and_return('3.')

    stub_command('modprobe -n -v aufs').and_return('')

    # TODO: Contribute back to golang cookbook
    stub_command('/usr/local/go/bin/go version | grep "go1.2 "').and_return('1.2')
  end

  
  context 'when running on ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::Runner.new.converge(described_recipe)
    end

    it 'includes the apt recipe' do
      expect(chef_run).to include_recipe('apt')
    end

    it 'installs the apt-transport-https package' do
      expect(chef_run).to install_package('apt-transport-https')
    end

    it 'installs the bsdtar package' do
      expect(chef_run).to install_package('bsdtar')
    end
  end

  context 'when running on debian 7.4' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'debian', version: '7.4').converge(described_recipe)
    end

    it 'includes the apt recipe' do
      expect(chef_run).to include_recipe('apt')
    end

    it 'installs the apt-transport-https package' do
      expect(chef_run).to install_package('apt-transport-https')
    end

    it 'installs the bsdtar package' do
      expect(chef_run).to install_package('bsdtar')
    end

    it 'sets net.ipv4.ip_forward to 1' do
      expect(chef_run).to apply_sysctl_param('net.ipv4.ip_forward').with(value: 1)
    end

    it 'sets net.ipv6.conf.all.forwarding to 1' do
      expect(chef_run).to apply_sysctl_param('net.ipv6.conf.all.forwarding').with(value: 1)
    end
  end

  context 'when exec_driver is lxc' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['exec_driver'] = 'lxc'
      runner.converge(described_recipe)
    end

    it 'includes the docker::cgroups recipe' do
      expect(chef_run).to include_recipe('docker::cgroups')
    end

    it 'includes the docker::lxc recipe' do
      expect(chef_run).to include_recipe('docker::lxc')
    end
  end

  context 'when install_type is binary' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['install_type'] = 'binary'
      runner.converge(described_recipe)
    end

    it 'includes the docker::binary recipe' do
      expect(chef_run).to include_recipe('docker::binary')
    end
  end

  context 'when running on ubuntu < 13.10' do
    context 'and install_type is binary and storage_driver is aufs' do
      let(:chef_run) do
        runner = ChefSpec::Runner.new
        runner.node.set['docker']['install_type'] = 'binary'
        runner.node.set['docker']['storage_driver'] = 'aufs'
        runner.converge(described_recipe)
      end

      it 'includes the docker::aufs recipe' do
        expect(chef_run).to include_recipe('docker::aufs')
      end
    end
  end

  context 'when running on ubuntu > 13.10' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '14.04')
      runner.node.set['docker']['install_type'] = 'binary'
      runner.node.set['docker']['storage_driver'] = 'aufs'
      runner.converge(described_recipe)
    end

    it 'should not manage the storagedriver' do
      expect(chef_run).not_to include_recipe('docker::aufs')
    end
  end

  context 'when install_type is source' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['docker']['install_type'] = 'source'
      runner.converge(described_recipe)
    end

    it 'includes the git recipe' do
      expect(chef_run).to include_recipe('git')
    end

    it 'includes the golang recipe' do
      expect(chef_run).to include_recipe('golang')
    end

    it 'includes the docker::source recipe' do
      expect(chef_run).to include_recipe('docker::source')
    end
  end

  context 'when the install_type is package' do
    let(:chef_run) do
      ChefSpec::Runner.new.converge(described_recipe)
    end

    it 'includes the docker::package recipe' do
      expect(chef_run).to include_recipe('docker::package')
    end
  end
  
  %w( runit systemd sysv ).each do |init|
    context "when init_type is #{init}" do
      let(:chef_run) do
        runner = ChefSpec::Runner.new
        runner.node.set['docker']['init_type'] = init
        runner.converge(described_recipe)
      end

      it "includes the docker::#{init} recipe" do
        expect(chef_run).to include_recipe("docker::#{init}")
      end
    end
  end
end
