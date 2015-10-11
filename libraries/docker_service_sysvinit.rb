class Chef
  class Resource
    class DockerServiceSysvinit < DockerService
      use_automatic_resource_name

      provides :docker_service, platform: 'amazon'
      provides :docker_service, platform: 'centos'
      provides :docker_service, platform: 'redhat'
      provides :docker_service, platform: 'suse'
      provides :docker_service, platform: 'debian'

      action :start do
        action_stop unless resource_changes.empty?
        # TODO: ^ convert this to the 12.5 way
        create_init
        create_service
        docker_wait_ready
      end

      action :stop do
        create_init
        s = create_service
        s.action :stop
      end

      action :restart do
        action_stop
        action_start
      end

      # FIXME: wtf is this? understand what this is, and document what
      # it does here in the cookbook.
      action_class.class_eval do
        def create_init
          template '/etc/init.d/docker' do
            path '/etc/init.d/docker'
            source 'sysvinit/docker.erb'
            owner 'root'
            group 'root'
            mode '0755'
            cookbook 'docker'
            variables(
              config: new_resource,
              docker_bin: docker_bin,
              docker_daemon_cmd: docker_daemon_cmd,
              docker_cmd: docker_cmd,
              docker_daemon_opts: docker_daemon_opts,
              docker_tls_ca_cert: tls_ca_cert,
              docker_tls_verify: tls_verify
            )
            action :create
          end
        end

        def create_service
          service 'docker' do
            provider Chef::Provider::Service::Init::Redhat if platform_family?('rhel')
            provider Chef::Provider::Service::Init::Debian if platform_family?('debian')
            supports restart: true, status: true
            action [:enable, :start]
          end
        end

        # TODO: figure out how to dedupe this from the execute class.
        # Ideally, the sysvinit script should handle the wait
        # internally, if it doesn't already.
        def docker_wait_ready
          # Try to connect to docker socket twenty times
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

      Chef::Provider::DockerService::Sysvinit = action_class unless defined?(Chef::Provider::DockerService::Sysvinit)
    end
  end
end
