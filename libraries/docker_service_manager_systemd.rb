module DockerCookbook
  class DockerServiceManagerSystemd < DockerServiceBase
    resource_name :docker_service_manager_systemd

    provides :docker_service_manager, platform: 'fedora'

    provides :docker_service_manager, platform: %w(redhat centos scientific) do |node| # ~FC005
      node['platform_version'].to_f >= 7.0
    end

    provides :docker_service_manager, platform: 'debian' do |node|
      node['platform_version'].to_f >= 8.0
    end

    provides :docker_service_manager, platform: 'ubuntu' do |node|
      node['platform_version'].to_f >= 15.04
    end

    property :service_timeout, Integer, default: 20

    def libexec_dir
      return '/usr/libexec/docker' if node['platform_family'] == 'rhel'
      '/usr/lib/docker'
    end

    action :start do
      directory libexec_dir do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end

      # this script is called by the main systemd unit file, and
      # spins around until the service is actually up and running.
      template "#{libexec_dir}/#{docker_name}-wait-ready" do
        source 'systemd/docker-wait-ready.erb'
        owner 'root'
        group 'root'
        mode '0755'
        variables(
          docker_cmd: docker_cmd,
          libexec_dir: libexec_dir,
          service_timeout: service_timeout
        )
        cookbook 'docker'
        action :create
      end

      # stock systemd unit file
      template "/lib/systemd/system/#{docker_name}.service" do
        source 'systemd/docker.service.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(docker_name: docker_name)
        cookbook 'docker'
        action :create
        not_if { docker_name == 'default' && ::File.exist?('/lib/systemd/system/docker.service') }
      end

      # stock systemd socket file
      template "/lib/systemd/system/#{docker_name}.socket" do
        source 'systemd/docker.socket.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(docker_name: docker_name)
        cookbook 'docker'
        action :create
        not_if { docker_name == 'default' && ::File.exist?('/lib/systemd/system/docker.socket') }
      end

      # this overrides the main systemd unit file
      template "/etc/systemd/system/#{docker_name}.service" do
        source 'systemd/docker.service-override.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          config: new_resource,
          docker_daemon_cmd: docker_daemon_cmd,
          docker_name: docker_name,
          libexec_dir: libexec_dir
        )
        cookbook 'docker'
        notifies :run, 'execute[systemctl daemon-reload]', :immediately
        notifies :restart, new_resource
        action :create
      end

      # this overrides the main systemd socket
      template "/etc/systemd/system/#{docker_name}.socket" do
        source 'systemd/docker.socket-override.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          config: new_resource,
          docker_name: docker_name
        )
        cookbook 'docker'
        notifies :run, 'execute[systemctl daemon-reload]', :immediately
        notifies :restart, new_resource
        action :create
      end

      # avoid 'Unit file changed on disk' warning
      execute 'systemctl daemon-reload' do
        command '/bin/systemctl daemon-reload'
        action :nothing
      end

      # service management resource
      service docker_name do
        provider Chef::Provider::Service::Systemd
        supports status: true
        action [:enable, :start]
        only_if { ::File.exist?("/lib/systemd/system/#{docker_name}.service") }
      end
    end

    action :stop do
      # service management resource
      service docker_name do
        provider Chef::Provider::Service::Systemd
        supports status: true
        action [:disable, :stop]
        only_if { ::File.exist?("/lib/systemd/system/#{docker_name}.service") }
      end
    end

    action :restart do
      action_stop
      action_start
    end
  end
end
