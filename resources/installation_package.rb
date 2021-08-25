unified_mode true
provides :docker_installation_package

property :setup_docker_repo, [true, false], default: true, desired_state: false
property :repo_channel, String, default: 'stable'
property :package_name, String, default: 'docker-ce', desired_state: false
property :package_version, String, desired_state: false
property :version, String, desired_state: false
property :package_options, String, desired_state: false

def version_string(ver)
  return if ver.nil?
  codename = if platform?('debian') && node['platform_version'].to_i == 9
               'stretch'
             elsif platform?('debian') && node['platform_version'].to_i == 10
               'buster'
             elsif platform?('ubuntu') && node['platform_version'] == '16.04'
               'xenial'
             elsif platform?('ubuntu') && node['platform_version'] == '18.04'
               'bionic'
             elsif platform?('ubuntu') && node['platform_version'] == '20.04'
               'focal'
             end

  # https://github.com/seemethere/docker-ce-packaging/blob/9ba8e36e8588ea75209d813558c8065844c953a0/deb/gen-deb-ver#L16-L20
  test_version = '3'

  if ver.to_f < 18.06 && !bionic?
    return "#{ver}~ce-0~debian" if platform?('debian')
    return "#{ver}~ce-0~ubuntu" if platform?('ubuntu')
  elsif ver.to_f >= 18.09 && platform_family?('debian')
    return "5:#{ver}~#{test_version}-0~debian-#{codename}" if platform?('debian')
    return "5:#{ver}~#{test_version}-0~ubuntu-#{codename}" if platform?('ubuntu')
  else
    return "#{ver}~ce~#{test_version}-0~debian" if platform?('debian')
    return "#{ver}~ce~#{test_version}-0~ubuntu" if platform?('ubuntu')
    ver
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
        elsif platform?('redhat') && arch == 's390x'
          'rhel'
        else
          'centos'
        end

      yum_repository 'Docker' do
        baseurl "https://download.docker.com/linux/#{platform}/#{node['platform_version'].to_i}/#{arch}/#{new_resource.repo_channel}"
        gpgkey "https://download.docker.com/linux/#{platform}/gpg"
        description "Docker #{new_resource.repo_channel.capitalize} repository"
        gpgcheck true
        enabled true
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

      package 'apt-transport-https'

      apt_repository 'Docker' do
        components Array(new_resource.repo_channel)
        uri "https://download.docker.com/linux/#{node['platform']}"
        arch deb_arch
        key "https://download.docker.com/linux/#{node['platform']}/gpg"
        action :add
      end
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
