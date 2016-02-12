module DockerCookbook
  class DockerServiceManagerUpstart < DockerServiceBase
    resource_name :docker_service_manager_upstart

    provides :docker_service_manager, platform: 'ubuntu'
    provides :docker_service_manager, platform: 'linuxmint'

    action :start do
      template "/etc/init/#{docker_name}.conf" do
        source 'upstart/docker.conf.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          docker_name: docker_name,
          docker_daemon_arg: docker_daemon_arg
        )
        cookbook 'docker'
        not_if { docker_name == 'default' && ::File.exist?('/etc/init/docker.conf') }
        action :create
      end

      template "/etc/default/#{docker_name}" do
        source 'default/docker.erb'
        variables(
          config: new_resource,
          docker_daemon_opts: docker_daemon_opts.join(' ')
        )
        cookbook 'docker'
        notifies :restart, new_resource
        action :create
      end

      service docker_name do
        provider Chef::Provider::Service::Upstart
        supports status: true
        action :start
      end

      # FIXME: why do we need this? This should be handled in init
      bash "docker-wait-ready #{name}" do
        code <<-EOF
            timeout=0
            while [ $timeout -lt 20 ];  do
              #{docker_cmd} ps | head -n 1 | grep ^CONTAINER
              if [ $? -eq 0 ]; then
                break
              fi
              ((timeout++))
              sleep 1
            done
            [[ $timeout -eq 20 ]] && exit 1
            exit 0
            EOF
        not_if "#{docker_cmd} ps | head -n 1 | grep ^CONTAINER"
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
