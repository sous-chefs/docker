class Chef
  class Resource
    class DockerServiceUpstart < DockerService
      use_automatic_resource_name

      provides :docker_service, platform: 'ubuntu'

      action :start do
        action_stop unless resource_changes.empty?

        template '/etc/default/docker' do
          source 'upstart/etc.default.docker.erb'
          mode '0644'
          owner 'root'
          group 'root'
          variables(
            config: new_resource,
            docker_bin: docker_bin,
            docker_daemon_opts: docker_daemon_opts
          )
          cookbook 'docker'
          action :create
        end

        template '/etc/init/docker.conf' do
          path '/etc/init/docker.conf'
          source 'upstart/docker.conf.erb'
          owner 'root'
          group 'root'
          mode '0644'
          variables(
            config: new_resource,
            docker_daemon_arg: docker_daemon_arg
          )
          cookbook 'docker'
          action :create
        end

        service 'docker' do
          provider Chef::Provider::Service::Upstart
          supports status: true
          action [:start]
        end

        # loop until docker socker is available
        docker_wait_ready
      end

      action :stop do
        service 'docker' do
          provider Chef::Provider::Service::Upstart
          supports restart: true, status: true
          action [:stop]
        end
      end

      action :restart do
        action_stop
        action_start
      end

      # FIXME: dedupe
      action_class.class_eval do
        # Try to connect to docker socket twenty times
        def docker_wait_ready
          bash 'docker-wait-ready' do
            code <<-EOF
            timeout=0
            while [ $timeout -lt 20 ];  do
              ((timeout++))
              #{docker_cmd} ps | head -n 1 | grep ^CONTAINER
                if [ $? -eq 0 ]; then
                  break
                fi
               sleep 1
            done
            [[ $timeout -eq 20 ]] && exit 1
            exit 0
            EOF
            not_if "#{docker_cmd} ps | head -n 1 | grep ^CONTAINER"
          end
        end
      end

      Chef::Provider::DockerService::Upstart = action_class unless defined?(Chef::Provider::DockerService::Execute)
    end
  end
end
