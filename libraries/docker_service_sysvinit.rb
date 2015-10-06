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

        create_init
        create_service

        # loop until docker socker is available
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
              docker_name: docker_name,
              docker_cmd: docker_cmd,
              docker_daemon_opts: docker_daemon_opts,
              docker_tls_ca_cert: tls_ca_cert,
              docker_tls_verify: tls_verify,
              pidfile: parsed_pidfile
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
      end

      Chef::Provider::DockerService::Sysvinit = action_class if !defined?(Chef::Provider::DockerService::Sysvinit)
    end
  end
end
