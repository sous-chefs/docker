# frozen_string_literal: true

unified_mode true
use '_partial/_base'

resource_name :docker_installation_package
provides :docker_installation_package

property :setup_docker_repo, [true, false], default: true, desired_state: false
property :repo_channel, String, default: 'stable'
property :package_name, String, default: lazy {
  if amazonlinux_2023? || fedora?
    'docker'
  else
    'docker-ce'
  end
}, desired_state: false
property :package_version, String, desired_state: false
property :version, String, desired_state: false
property :package_options, String, desired_state: false
property :site_url, String, default: 'download.docker.com'

def el7?
  return true if platform_family?('rhel') && node['platform_version'].to_i == 7
  false
end

def el8?
  return true if platform_family?('rhel') && node['platform_version'].to_i == 8
  false
end

def fedora?
  return true if platform?('fedora')
  false
end

def debuntu?
  return true if platform_family?('debian')
  false
end

def debian?
  return true if platform?('debian')
  false
end

def ubuntu?
  return true if platform?('ubuntu')
  false
end

def bookworm?
  return true if platform?('debian') && node['platform_version'].to_i == 12
  false
end

def trixie?
  return true if platform?('debian') && node['platform_version'].to_i == 13
  false
end

def jammy?
  return true if platform?('ubuntu') && node['platform_version'] == '22.04'
  false
end

def noble?
  return true if platform?('ubuntu') && node['platform_version'] == '24.04'
  false
end

def amazonlinux_2023?
  return true if platform?('amazon') && node['platform_version'] == '2023'
  false
end

# https://github.com/chef/chef/issues/4103
def version_string(v)
  return if v.nil?
  codename = if bookworm? # deb 12
               'bookworm'
             elsif trixie? # deb 13
               'trixie'
             elsif jammy? # ubuntu 22.04
               'jammy'
             elsif noble? # ubuntu 24.04
               'noble'
             end

  # https://github.com/seemethere/docker-ce-packaging/blob/9ba8e36e8588ea75209d813558c8065844c953a0/deb/gen-deb-ver#L16-L20
  test_version = '3'

  if v.to_f >= 23.0 && ubuntu?
    "5:#{v}-1~ubuntu.#{node['platform_version']}~#{codename}"
  elsif v.to_f >= 18.09 && debuntu?
    return "5:#{v}~#{test_version}-0~debian-#{codename}" if debian?
    "5:#{v}~#{test_version}-0~ubuntu-#{codename}" if ubuntu?
  else
    return "#{v}~ce~#{test_version}-0~debian" if debian?
    return "#{v}~ce~#{test_version}-0~ubuntu" if ubuntu?
    v
  end
end

action :create do
  if new_resource.setup_docker_repo
    if platform_family?('rhel', 'fedora')
      arch = node['kernel']['machine']
      platform =
        if platform?('fedora')
          'fedora'
          # s390x is only available under rhel platform
        elsif platform?('redhat', 'oracle') && (arch == 's390x' || !el7?)
          'rhel'
          # use rhel for all el8 since CentOS 8 is dead
        elsif el8? && !platform?('centos')
          'rhel'
        else
          'centos'
        end

      yum_repository 'docker' do
        baseurl "https://#{new_resource.site_url}/linux/#{platform}/#{node['platform_version'].to_i}/#{arch}/#{new_resource.repo_channel}"
        gpgkey "https://#{new_resource.site_url}/linux/#{platform}/gpg"
        description "Docker #{new_resource.repo_channel.capitalize} repository"
        gpgcheck true
        enabled true
      end

      # These have conflicting dependencies and need to be removed
      package %w(buildah podman) do
        action :remove
      end
    elsif platform_family?('debian')
      deb_arch =
        case node['kernel']['machine']
        when 'x86_64'
          'amd64'
        when 'aarch64'
          'arm64'
        when 'armv7l'
          'armhf'
        when 'ppc64le'
          'ppc64el'
        else
          node['kernel']['machine']
        end

      apt_update 'apt-transport-https'

      package 'apt-transport-https'

      # Some platforms don't have this directory
      directory '/etc/apt/keyrings'

      apt_repository 'docker' do
        components Array(new_resource.repo_channel)
        uri "https://#{new_resource.site_url}/linux/#{node['platform']}"
        arch deb_arch
        key "https://#{new_resource.site_url}/linux/#{node['platform']}/gpg"
        # TODO: This eventually should go away once Debian 12 and Ubuntu 24.04 go EOL
        if (debian? && node['platform_version'].to_i < 13) || (ubuntu? && node['platform_version'].to_f <= 24.04)
          signed_by false
        end if Gem::Version.new('18.7.10') <= Chef::VERSION
        action :add
      end

      apt_update 'docker'
    else
      Chef::Log.warn("Cannot setup the Docker repo for platform #{node['platform']}. Skipping.")
    end
  end

  version = new_resource.package_version || version_string(new_resource.version)

  package new_resource.package_name do
    version version
    options new_resource.package_options
    action :install
  end
end

action :delete do
  package new_resource.package_name do
    action :remove
  end
end
