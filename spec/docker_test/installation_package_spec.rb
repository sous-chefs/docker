require 'spec_helper'

describe 'docker_test::installation_package' do
  platform 'ubuntu', '18.04'
  step_into :docker_installation_package
  cached(:subject) { chef_run }

  context 'Ubuntu: testing default action, default properties' do
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default').with(version: '20.10.1')
    end

    it do
      expect(chef_run).to add_apt_repository('Docker').with(
        components: %w(stable),
        uri: 'https://download.docker.com/linux/ubuntu',
        arch: 'amd64',
        key: %w(https://download.docker.com/linux/ubuntu/gpg)
      )
    end
  end

  context 'Ubuntu (aarch64): testing default action, default properties' do
    automatic_attributes['kernel']['machine'] = 'aarch64'
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default').with(version: '20.10.1')
    end

    it do
      expect(chef_run).to add_apt_repository('Docker').with(
        components: %w(stable),
        uri: 'https://download.docker.com/linux/ubuntu',
        arch: 'arm64',
        key: %w(https://download.docker.com/linux/ubuntu/gpg)
      )
    end
  end

  context 'Ubuntu (ppc64le): testing default action, default properties' do
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default').with(version: '20.10.1')
    end

    it do
      expect(chef_run).to add_apt_repository('Docker').with(
        components: %w(stable),
        uri: 'https://download.docker.com/linux/ubuntu',
        arch: 'ppc64el',
        key: %w(https://download.docker.com/linux/ubuntu/gpg)
      )
    end
  end

  context 'CentOS: testing default action, default properties' do
    platform 'centos', '8'
    cached(:subject) { chef_run }
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default').with(version: '3:20.10.1')
    end
    it do
      expect(chef_run).to create_yum_repository('Docker').with(
        baseurl: 'https://download.docker.com/linux/centos/8/x86_64/stable',
        gpgkey: 'https://download.docker.com/linux/centos/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  context 'CentOS (s390x): testing default action, default properties' do
    platform 'redhat', '8'
    cached(:subject) { chef_run }
    automatic_attributes['kernel']['machine'] = 's390x'

    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default').with(version: '3:20.10.1')
    end
    it do
      expect(chef_run).to create_yum_repository('Docker').with(
        baseurl: 'https://download.docker.com/linux/rhel/8/s390x/stable',
        gpgkey: 'https://download.docker.com/linux/rhel/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end
end
