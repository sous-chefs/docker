# frozen_string_literal: true

require 'spec_helper'

describe 'test::installation_package' do
  platform 'ubuntu'
  step_into :docker_installation_package
  cached(:subject) { chef_run }

  context 'Ubuntu: testing default action, default properties' do
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end

    it do
      expect(chef_run).to add_apt_repository('docker').with(
        components: %w(stable),
        uri: 'https://download.docker.com/linux/ubuntu',
        arch: 'amd64',
        signed_by: false,
        key: %w(https://download.docker.com/linux/ubuntu/gpg)
      )
    end
  end

  context 'Ubuntu (aarch64): testing default action, default properties' do
    automatic_attributes['kernel']['machine'] = 'aarch64'
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end

    it do
      expect(chef_run).to add_apt_repository('docker').with(
        components: %w(stable),
        uri: 'https://download.docker.com/linux/ubuntu',
        arch: 'arm64',
        signed_by: false,
        key: %w(https://download.docker.com/linux/ubuntu/gpg)
      )
    end
  end

  context 'Ubuntu (ppc64le): testing default action, default properties' do
    automatic_attributes['kernel']['machine'] = 'ppc64le'
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end

    it do
      expect(chef_run).to add_apt_repository('docker').with(
        components: %w(stable),
        uri: 'https://download.docker.com/linux/ubuntu',
        arch: 'ppc64el',
        signed_by: false,
        key: %w(https://download.docker.com/linux/ubuntu/gpg)
      )
    end
  end

  context 'CentOS Stream 10: testing default action, default properties' do
    platform 'centos-stream', '9'
    cached(:subject) { chef_run }
    automatic_attributes['platform_version'] = '10'

    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end

    it do
      expect(chef_run).to create_yum_repository('docker').with(
        baseurl: 'https://download.docker.com/linux/centos/10/x86_64/stable',
        gpgkey: 'https://download.docker.com/linux/centos/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  context 'CentOS 9: testing default action, default properties' do
    platform 'centos-stream', '9'
    cached(:subject) { chef_run }

    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end
    it do
      expect(chef_run).to create_yum_repository('docker').with(
        baseurl: 'https://download.docker.com/linux/centos/9/x86_64/stable',
        gpgkey: 'https://download.docker.com/linux/centos/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  context 'RHEL (s390x): testing default action, default properties' do
    platform 'redhat', '8'
    cached(:subject) { chef_run }
    automatic_attributes['kernel']['machine'] = 's390x'

    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end
    it do
      expect(chef_run).to create_yum_repository('docker').with(
        baseurl: 'https://download.docker.com/linux/rhel/8/s390x/stable',
        gpgkey: 'https://download.docker.com/linux/rhel/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  context 'RHEL 8: testing default action, default properties' do
    platform 'redhat', '8'
    cached(:subject) { chef_run }

    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end
    it do
      expect(chef_run).to create_yum_repository('docker').with(
        baseurl: 'https://download.docker.com/linux/rhel/8/x86_64/stable',
        gpgkey: 'https://download.docker.com/linux/rhel/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  context 'RHEL 9: testing default action, default properties' do
    platform 'redhat', '9'
    cached(:subject) { chef_run }

    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end
    it do
      expect(chef_run).to create_yum_repository('docker').with(
        baseurl: 'https://download.docker.com/linux/rhel/9/x86_64/stable',
        gpgkey: 'https://download.docker.com/linux/rhel/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  context 'Oracle 7: testing default action, default properties' do
    platform 'oracle', '7'
    cached(:subject) { chef_run }
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end
    it do
      expect(chef_run).to create_yum_repository('docker').with(
        baseurl: 'https://download.docker.com/linux/centos/7/x86_64/stable',
        gpgkey: 'https://download.docker.com/linux/centos/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  context 'Oracle 8: testing default action, default properties' do
    platform 'oracle', '8'
    cached(:subject) { chef_run }
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end
    it do
      expect(chef_run).to create_yum_repository('docker').with(
        baseurl: 'https://download.docker.com/linux/rhel/8/x86_64/stable',
        gpgkey: 'https://download.docker.com/linux/rhel/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  context 'Oracle 9: testing default action, default properties' do
    platform 'oracle', '9'
    cached(:subject) { chef_run }
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default')
    end
    it do
      expect(chef_run).to create_yum_repository('docker').with(
        baseurl: 'https://download.docker.com/linux/rhel/9/x86_64/stable',
        gpgkey: 'https://download.docker.com/linux/rhel/gpg',
        description: 'Docker Stable repository',
        gpgcheck: true,
        enabled: true
      )
    end
  end

  # Coverage of all recent docker versions
  # To ensure test coverage and backwards compatibility
  # With the frequent changes in package naming convention
  # List generated from
  # https://download.docker.com/linux/ubuntu/dists/#{distro}/stable/binary-amd64/Packages

  context 'version strings for Debian 12' do
    platform 'debian', '12'
    cached(:subject) { chef_run }
    [
      { docker_version: '24.0.0', expected: '5:24.0.0~3-0~debian-bookworm' },
    ].each do |suite|
      it 'generates the correct version string debian bookworm' do
        custom_resource = chef_run.docker_installation_package('default')
        actual = custom_resource.version_string(suite[:docker_version])
        expect(actual).to eq(suite[:expected])
      end
    end
  end

  context 'version strings for Debian 13' do
    platform 'debian', '13'
    cached(:subject) { chef_run }
    [
      { docker_version: '27.0.0', expected: '5:27.0.0~3-0~debian-trixie' },
    ].each do |suite|
      it 'generates the correct version string debian trixie' do
        custom_resource = chef_run.docker_installation_package('default')
        actual = custom_resource.version_string(suite[:docker_version])
        expect(actual).to eq(suite[:expected])
      end
    end
  end

  context 'version strings for Ubuntu 22.04' do
    platform 'ubuntu', '22.04'
    cached(:subject) { chef_run }
    [
      { docker_version: '24.0.0', expected: '5:24.0.0-1~ubuntu.22.04~jammy' },
    ].each do |suite|
      it 'generates the correct version string ubuntu jammy' do
        custom_resource = chef_run.docker_installation_package('default')
        actual = custom_resource.version_string(suite[:docker_version])
        expect(actual).to eq(suite[:expected])
      end
    end
  end

  context 'version strings for Ubuntu 24.04' do
    platform 'ubuntu', '24.04'
    cached(:subject) { chef_run }
    [
      { docker_version: '26.0.0', expected: '5:26.0.0-1~ubuntu.24.04~noble' },
    ].each do |suite|
      it 'generates the correct version string ubuntu noble' do
        custom_resource = chef_run.docker_installation_package('default')
        actual = custom_resource.version_string(suite[:docker_version])
        expect(actual).to eq(suite[:expected])
      end
    end
  end
end
