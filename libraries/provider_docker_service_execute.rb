class Chef
  class Provider
    class DockerService
      class Execute < Chef::Provider::DockerService
        if Chef::Provider.respond_to?(:provides)
          provides :docker_service, os: ' linux'
        end

        # Start the service
        action :start do
          action_stop unless resource_changes.empty?

          # enable ipv6 forwarding
          execute 'enable net.ipv6.conf.all.forwarding' do
            command '/sbin/sysctl net.ipv6.conf.all.forwarding=1'
            not_if '/sbin/sysctl -q -n net.ipv6.conf.all.forwarding | grep ^1$'
            action :run
          end

          # Go doesn't support detaching processes natively, so we have
          # to manually fork it from the shell with &
          # https://github.com/docker/docker/issues/2758
          bash 'start docker' do
            code "#{docker_daemon_cmd} &>> #{new_resource.logfile} &"
            environment 'HTTP_PROXY' => new_resource.http_proxy,
                        'HTTPS_PROXY' => new_resource.https_proxy,
                        'NO_PROXY' => new_resource.no_proxy,
                        'TMPDIR' => new_resource.tmpdir
            not_if "ps -ef | awk '{ print $8 }' | grep ^#{docker_bin}$"
            action :run
          end

          # loop until docker socker is available
          docker_wait_ready
        end

        action :stop do
          execute 'stop docker' do
            command 'kill `pidof docker`'
            only_if "ps -ef | awk '{ print $8 }' | grep ^#{docker_bin}$"
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
