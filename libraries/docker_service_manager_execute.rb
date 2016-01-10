module DockerCookbook
  class DockerServiceManagerExecute < DockerServiceBase
    use_automatic_resource_name

    provides :docker_service_manager, os: 'linux'

    # Start the service
    action :start do
      # enable ipv4 forwarding
      execute 'enable net.ipv4.conf.all.forwarding' do
        command '/sbin/sysctl net.ipv4.conf.all.forwarding=1'
        not_if '/sbin/sysctl -q -n net.ipv4.conf.all.forwarding | grep ^1$'
        action :run
      end

      # enable ipv6 forwarding
      execute 'enable net.ipv6.conf.all.forwarding' do
        command '/sbin/sysctl net.ipv6.conf.all.forwarding=1'
        not_if '/sbin/sysctl -q -n net.ipv6.conf.all.forwarding | grep ^1$'
        action :run
      end

      # Go doesn't support detaching processes natively, so we have
      # to manually fork it from the shell with &
      # https://github.com/docker/docker/issues/2758
      bash "start docker #{name}" do
        code "#{docker_daemon_cmd} >> #{logfile} 2>&1 &"
        environment 'HTTP_PROXY' => http_proxy,
                    'HTTPS_PROXY' => https_proxy,
                    'NO_PROXY' => no_proxy,
                    'TMPDIR' => tmpdir
        not_if "ps -ef | grep -v grep | grep #{Shellwords.escape(docker_daemon_cmd)}"
        action :run
      end

      # loop until docker docker is available
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

    action :stop do
      execute "stop docker #{name}" do
        command "kill `cat #{pidfile}`"
        only_if "#{docker_cmd} ps | head -n 1 | grep ^CONTAINER"
      end
    end

    action :restart do
      action_stop
      action_start
    end
  end
end
