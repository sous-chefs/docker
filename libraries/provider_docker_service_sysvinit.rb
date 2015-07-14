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
          template '/etc/init.d/docker' do
            path '/etc/init.d/docker'
            source 'sysvinit/docker.erb'
            owner 'root'
            group 'root'
            mode '0755'
            cookbook 'docker'
            variables(
              config: new_resource,
              docker_opts: docker_opts,
              pidfile: parsed_pidfile
            )
            action :create
          end

          service 'docker' do
            provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
            provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
            supports restart: true, status: true
            action [:enable, :start]
          end
        end

        action :stop do
          service 'docker' do
            provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
            provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
            supports restart: true, status: true
            action [:stop]
          end
        end

        action :restart do
          service 'docker' do
            provider Chef::Provider::Service::Init::Redhat if node['platform_family'] == 'redhat'
            provider Chef::Provider::Service::Init::Insserv if node['platform_family'] == 'debian'
            action :reload
          end
        end
      end
    end
  end
end
