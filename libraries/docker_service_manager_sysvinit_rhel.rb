module DockerCookbook
  class DockerServiceManagerSysvinitRhel < DockerServiceBase
    resource_name :docker_service_manager_sysvinit_rhel

    provides :docker_service_manager, platform: 'amazon'
    provides :docker_service_manager, platform: 'suse'
    provides :docker_service_manager, platform: %w(redhat centos scientific) do |node| # ~FC005
      node['platform_version'].to_f <= 7.0
    end

    provides :docker_service_manager_sysvinit, platform: 'amazon'
    provides :docker_service_manager_sysvinit, platform: 'suse'
    provides :docker_service_manager_sysvinit, platform: %w(redhat centos scientific) do |node| # ~FC005
      node['platform_version'].to_f <= 7.0
    end

    action :start do
      create_init
      create_service
      wait_ready
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
          source 'sysvinit/docker-rhel.erb'
          owner 'root'
          group 'root'
          mode '0755'
          variables(
            docker_name: docker_name,
            docker_daemon_arg: docker_daemon_arg
          )
          cookbook 'docker'
          not_if { docker_name == 'docker' && ::File.exist?('/etc/init.d/docker') }
          action :create
        end

        template "/etc/sysconfig/#{docker_name}" do
          source 'sysconfig/docker.erb'
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
          supports restart: true, status: true
          action [:enable, :start]
        end
      end

      def wait_ready
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
    end
  end
end
