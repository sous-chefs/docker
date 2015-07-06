class Chef
  class Provider
    class DockerService
      class Execute < Chef::Provider::DockerService
        if Chef::Provider.respond_to?(:provides)
          provides :docker_service, os: ' linux'
        end

        # Start the service
        action :start do
          # Go doesn't support detaching processes natively, so we have
          # to manually fork it from the shell with &
          # https://github.com/docker/docker/issues/2758
          bash 'start docker' do
            code "#{docker_daemon_cmd} &>> #{docker_log} &"
            environment 'HTTP_PROXY' => new_resource.http_proxy,
                        'HTTPS_PROXY' => new_resource.https_proxy,
                        'NO_PROXY' => new_resource.no_proxy,
                        'TMPDIR' => new_resource.tmpdir
            not_if "ps -ef | awk '{ print $8 }' | grep ^#{docker_bin}$"
            action :run
          end
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
