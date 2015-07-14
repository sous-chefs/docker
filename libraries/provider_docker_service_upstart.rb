class Chef
  class Provider
    class DockerService
      class Upstart < Chef::Provider::DockerService
        if Chef::Provider.respond_to?(:provides)
          provides :docker_service, platform: 'ubuntu'
        end

        action :start do
          template '/etc/default/docker' do
            source 'upstart/etc.default.docker.erb'
            mode '0644'
            owner 'root'
            group 'root'
            variables(
              config: new_resource,
              docker_bin: docker_bin,
              docker_opts: docker_opts
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
              docker_daemon_cmd: docker_daemon_cmd
            )
            cookbook 'docker'
            action :create
          end

          service 'docker' do
            provider Chef::Provider::Service::Upstart
            supports status: true
            action [:start]
          end
        end

        action :stop do
          service 'docker' do
            provider Chef::Provider::Service::Upstart
            supports restart: true, status: true
            action [:stop]
          end
        end

        action :restart do
          service 'docker' do
            provider Chef::Provider::Service::Upstart
            action :stop
          end

          service 'docker' do
            provider Chef::Provider::Service::Upstart
            action :start
          end
        end
      end
    end
  end
end
