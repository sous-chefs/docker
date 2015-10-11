class Chef
  class Resource
    class DockerServiceSystemd < DockerService
      use_automatic_resource_name

      provides :docker_service, platform: 'fedora'

      provides :docker_service, platform: %w(redhat centos scientific) do |node| # ~FC005
        node['platform_version'].to_f >= 7.0
      end

      provides :docker_service, platform: 'debian' do |node|
        node['platform_version'].to_f >= 8.0
      end

      provides :docker_service, platform: 'ubuntu' do |node|
        node['platform_version'].to_f >= 15.04
      end

      action :start do
        action_stop unless resource_changes.empty?

        # this is the main systemd unit file
        template '/lib/systemd/system/docker.service' do
          path '/lib/systemd/system/docker.service'
          source 'systemd/docker.service.erb'
          owner 'root'
          group 'root'
          mode '0644'
          variables(
            config: new_resource,
            docker_bin: docker_bin,
            docker_daemon_arg: docker_daemon_arg,
            docker_daemon_opts: docker_daemon_opts
          )
          cookbook 'docker'
          notifies :run, 'execute[systemctl daemon-reload]', :immediately
          action :create
        end

        # avoid 'Unit file changed on disk' warning
        execute 'systemctl daemon-reload' do
          command '/bin/systemctl daemon-reload' if node['platform'] == 'ubuntu' || node['platform'] == 'debian'
          command '/usr/bin/systemctl daemon-reload' unless node['platform'] == 'ubuntu' || node['platform'] == 'debian'
          action :nothing
        end

        # tmpfiles.d config so the service survives reboot
        template '/usr/lib/tmpfiles.d/docker.conf' do
          path '/usr/lib/tmpfiles.d/docker.conf'
          source 'systemd/tmpfiles.d.conf.erb'
          owner 'root'
          group 'root'
          mode '0644'
          variables(config: new_resource)
          cookbook 'docker'
          action :create
        end

        # service management resource
        service 'docker' do
          provider Chef::Provider::Service::Systemd
          supports restart: true, status: true
          action [:enable, :start]
        end

        # loop until docker socker is available
        docker_wait_ready
      end

      action :stop do
        # service management resource
        service 'docker' do
          provider Chef::Provider::Service::Systemd
          supports status: true
          action [:disable, :stop]
          only_if { ::File.exist?('/lib/systemd/system/docker.service') }
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

      Chef::Provider::DockerService::Systemd = action_class unless defined?(Chef::Provider::DockerService::Systemd)
    end
  end
end
