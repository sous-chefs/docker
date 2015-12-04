module DockerCookbook
  class DockerServiceManagerSysvinit < DockerServiceBase
    use_automatic_resource_name

    provides :docker_service_manager, platform: 'amazon'
    provides :docker_service_manager, platform: 'centos'
    provides :docker_service_manager, platform: 'redhat'
    provides :docker_service_manager, platform: 'suse'
    provides :docker_service_manager, platform: 'debian'

    action :start do
      create_init
      create_service
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
        template "/etc/init.d/#{docker_name}" do
          source 'sysvinit/docker.erb'
          owner 'root'
          group 'root'
          mode '0755'
          cookbook 'docker'
          variables(
            config: new_resource,
            docker_bin: docker_bin,
            docker_cmd: docker_cmd,
            docker_daemon_cmd: docker_daemon_cmd,
            docker_daemon_opts: docker_daemon_opts,
            docker_name: docker_name,
            docker_tls_ca_cert: tls_ca_cert,
            docker_tls_verify: tls_verify
          )
          action :create
          notifies :restart, new_resource
        end
      end

      def create_service
        service docker_name do
          provider Chef::Provider::Service::Init::Redhat if platform_family?('rhel')
          provider Chef::Provider::Service::Init::Debian if platform_family?('debian')
          supports restart: true, status: true
          action [:enable, :start]
        end
      end
    end
  end
end
