module DockerCookbook
  class DockerServiceManagerUpstart < DockerServiceBase
    use_automatic_resource_name

    provides :docker_service_manager, platform: 'ubuntu'

    action :start do
      template '/etc/init/docker.conf' do
        path '/etc/init/docker.conf'
        source 'upstart/docker.conf.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          config: new_resource,
          docker_cmd: docker_cmd,
          docker_daemon_cmd: docker_daemon_cmd
        )
        cookbook 'docker'
        notifies :restart, new_resource
        action :create
      end

      service 'docker' do
        provider Chef::Provider::Service::Upstart
        supports status: true
        action :start
      end
    end

    action :stop do
      service 'docker' do
        provider Chef::Provider::Service::Upstart
        supports status: true
        action :stop
      end
    end

    action :restart do
      action_stop
      action_start
    end

    Chef::Provider::DockerService::Upstart = action_class unless defined?(Chef::Provider::DockerService::Execute)
  end
end
