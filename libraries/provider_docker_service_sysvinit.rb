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
              docker_opts: docker_opts,
              docker_tlscacert: new_resource.tlscacert,
              docker_tlsverify: new_resource.tlsverify,
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
          bash 'docker-wait-ready' do
            env_h = {}
            env_h['DOCKER_HOST'] = new_resource.host unless new_resource.host.nil?
            env_h['DOCKER_CERT_PATH'] = ::File.dirname(new_resource.tlscacert) unless new_resource.tlscacert.nil?
            env_h['DOCKER_TLS_VERIFY'] = '1' if new_resource.tlsverify == true
            environment env_h
            code <<-EOF
            echo "DOCKER_HOST: $DOCKER_HOST"
            echo "DOCKER_CERT_PATH: $DOCKER_CERT_PATH"
            echo "DOCKER_TLS_VERIFY: $DOCKER_TLS_VERIFY"
            while /bin/true; do
              docker ps | head -n 1 | grep ^CONTAINER
              if [ $? -eq 0 ]; then
                break
              fi
              sleep 1
            done
            EOF
            not_if 'docker ps | head -n 1 | grep ^CONTAINER', environment: env_h
          end
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
              docker_opts: docker_opts,
              docker_tlscacert: new_resource.tlscacert,
              docker_tlsverify: new_resource.tlsverify,
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
