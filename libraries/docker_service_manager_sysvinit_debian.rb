module DockerCookbook
  class DockerServiceManagerSysvinitDebian < DockerServiceBase
    resource_name :docker_service_manager_sysvinit_debian

    provides :docker_service_manager, platform: 'debian' do |node|
      node['platform_version'].to_f < 8.0
    end

    provides :docker_service_manager, platform: 'ubuntu' do |node|
      node['platform_version'].to_f < 12.04
    end

    provides :docker_service_manager_sysvinit, platform: 'debian' do |node|
      node['platform_version'].to_f < 8.0
    end

    provides :docker_service_manager_sysvinit, platform: 'ubuntu' do |node|
      node['platform_version'].to_f < 12.04
    end

    action :start do
      create_docker_wait_ready
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

    action_class.class_eval do
      def create_init
        execute 'groupadd docker' do
          not_if 'getent group docker'
          action :run
        end

        link "/usr/bin/#{docker_name}" do
          to '/usr/bin/docker'
          link_type :hard
          action :create
          not_if { docker_name == 'docker' }
        end

        template "/etc/init.d/#{docker_name}" do
          source 'sysvinit/docker-debian.erb'
          owner 'root'
          group 'root'
          mode '0755'
          variables(
            docker_name: docker_name,
            docker_daemon_arg: docker_daemon_arg,
            docker_wait_ready: "#{libexec_dir}/#{docker_name}-wait-ready"
          )
          cookbook 'docker'
          action :create
        end

        template "/etc/default/#{docker_name}" do
          source 'default/docker.erb'
          variables(
            config: new_resource,
            docker_daemon_opts: docker_daemon_opts.join(' ')
          )
          cookbook 'docker'
          notifies :restart, new_resource, :immediately
          action :create
        end
      end

      def create_service
        service docker_name do
          provider Chef::Provider::Service::Init::Debian
          supports restart: true, status: true
          action [:enable, :start]
        end
      end
    end
  end
end
