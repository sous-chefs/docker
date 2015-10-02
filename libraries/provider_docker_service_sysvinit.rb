class Chef
  class Provider
    class DockerService
      class Sysvinit < Chef::Provider::DockerService
        if Chef::Provider.respond_to?(:provides)
          provides :docker_service, platform: 'amazon'
          provides :docker_service, platform: 'centos'
          provides :docker_service, platform: 'redhat'
          provides :docker_service, platform: 'suse'
          provides :docker_service, platform: 'debian'
        end

        action :start do
          action_stop unless resource_changes.empty?

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
              docker_host: new_resource.host,
              docker_name: docker_name,
              docker_daemon_opts: docker_daemon_opts,
              docker_tls_ca_cert: new_resource.tls_ca_cert,
              docker_tls_verify: new_resource.tls_verify,
              pidfile: parsed_pidfile
            )
            action :create
          end

          service 'docker' do
            provider Chef::Provider::Service::Init::Redhat if platform_family?('rhel')
            provider Chef::Provider::Service::Init::Debian if platform_family?('debian')
            supports restart: true, status: true
            action [:enable, :start]
          end

          # loop until docker socker is available
          docker_wait_ready
        end

        action :stop do
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
              docker_host: new_resource.host,
              docker_name: docker_name,
              docker_daemon_opts: docker_daemon_opts,
              docker_tls_ca_cert: new_resource.tls_ca_cert,
              docker_tls_verify: new_resource.tls_verify,
              pidfile: parsed_pidfile
            )
            action :create
          end

          service 'docker' do
            provider Chef::Provider::Service::Init::Redhat if platform_family?('rhel')
            provider Chef::Provider::Service::Init::Insserv if platform_family?('debian')
            supports restart: false, status: true
            action [:stop]
          end
        end

        action :restart do
          action_stop
          action_start
        end
      end
    end
  end
end
