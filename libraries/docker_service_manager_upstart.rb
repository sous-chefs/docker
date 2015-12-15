module DockerCookbook
  class DockerServiceManagerUpstart < DockerServiceBase
    use_automatic_resource_name

    provides :docker_service_manager, platform: 'ubuntu'
    provides :docker_service_manager, platform: 'linuxmint'

    action :start do
      template "/etc/init/#{docker_name}.conf" do
        source 'upstart/docker.conf.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          config: new_resource,
          docker_name: docker_name,
          docker_cmd: docker_cmd,
          docker_daemon_cmd: docker_daemon_cmd
        )
        cookbook 'docker'
        notifies :restart, new_resource unless ::File.exist? "/etc/#{docker_name}-firstconverge"
        notifies :restart, new_resource if auto_restart
        action :create
      end

      file "/etc/#{docker_name}-firstconverge" do
        action :create
      end

      service docker_name do
        provider Chef::Provider::Service::Upstart
        supports status: true
        action :start
      end
    end

    action :stop do
      service docker_name do
        provider Chef::Provider::Service::Upstart
        supports status: true
        action :stop
      end
    end

    action :restart do
      action_stop
      action_start
    end
  end
end
