# docker_container

The `docker_container` is responsible for managing Docker container actions. It speaks directly to the [Docker remote API](https://docs.docker.com/reference/api/docker_remote_api_v1.20/).

Containers are process oriented, and move through an event cycle.

## Actions

- `:create` - Creates the container but does not start it. Useful for Volume containers.
- `:start` - Starts the container. Useful for containers that run jobs.. command that exit.
- `:run` - The default action. Both `:create` and `:start` the container in one action. Redeploys the container on resource change.
- `:run_if_missing` - Runs a container only once.
- `:stop` - Stops the container.
- `:restart` - Stops and then starts the container.
- `:kill` - Send a signal to the container process. Defaults to `SIGKILL`.
- `:pause` - Pauses the container.
- `:unpause` - Unpauses the container.
- `:delete` - Deletes the container.
- `:redeploy` - Deletes and runs the container.
- `:reload` - Sends SIGHUP to pid 1 in the container by default. Can be changed with `reload_signal`.

## Properties

Most `docker_container` properties are the `snake_case` version of the `CamelCase` keys found in the [Docker Remote Api](https://docs.docker.com/reference/api/docker_remote_api_v1.20/)

- `container_name` - The name of the container. Defaults to the name of the `docker_container` resource.
- `repo` - aka `image_name`. The first half of a the complete identifier for a Docker Image.
- `tag` - The second half of a Docker image's identity. - Defaults to `latest`.
- `command` - The command to run when starting the container.
- `autoremove` - Boolean - Automatically delete a container when it's command exits. Defaults to `false`.
- `volumes` - An array of volume bindings for this container. Each volume binding is a string in one of these forms: `container_path` to create a new volume for the container. `host_path:container_path` to bind-mount a host path into the container. `host_path:container_path:ro` to make the bind-mount read-only inside the container.
- `cap_add` - An array Linux Capabilities (`man 7 capabilities`) to add to grant the container beyond what it normally gets.
- `cap_drop` - An array Linux Capabilities (`man 7 capabilities`) to revoke that the container normally has.
- `cpus` - A float or integer value specifying how much of the available CPU resources a container can use. Available in Docker 1.13 and higher.
- `cpu_shares` - An integer value containing the CPU Shares for the container.
- `devices` - A Hash of devices to add to the container.
- `dns` - An array of DNS servers the container will use for name resolution.
- `dns_search` - An array of domains the container will search for name resolution.
- `domain_name` - Set's the container's dnsdomainname as returned by the `dnsdomainname` command.
- `entrypoint` - Set the entry point for the container as a string or an array of strings.
- `env` - Set environment variables in the container in the form `['FOO=bar', 'BIZ=baz']`
- `env_file` - Read environment variables from a file and set in the container. Accepts an Array or String to the file location. lazy evaluator must be set if the file passed is created by Chef.
- `extra_hosts` - An array of hosts to add to the container's `/etc/hosts` in the form `['host_a:10.9.8.7', 'host_b:10.9.8.6']`
- `force` - A boolean to use in container operations that support a `force` option. Defaults to `false`
- `health_check` - A hash containing the health check options - [healthcheck reference](https://docs.docker.com/engine/reference/run/#healthcheck)
- `host` - A string containing the host the API should communicate with. Defaults to ENV['DOCKER_HOST'] if set
- `host_name` - The hostname for the container.
- `labels` A string, array, or hash to set metadata on the container in the form ['foo:bar', 'hello:world']`
- `links` - An array of source container/alias pairs to link the container to in the form `[container_a:www', container_b:db']`
- `log_driver` - Sets a custom logging driver for the container (json-file/syslog/journald/gelf/fluentd/awslogs/splunk/etwlogs/gcplogs/logentries/loki-docker/local/none).
- `log_opts` - Configures the above logging driver options (driver-specific).
- `init` - Run an init inside the container that forwards signals and reaps processes.
- `ip_address` - Container IPv4 address (e.g. 172.30.100.104)
- `mac_address` - The mac address for the container to use.
- `memory` - Memory limit in bytes.
- `memory_swap` - Total memory limit (memory + swap); set `-1` to disable swap limit (unlimited). You must use this with memory and make the swap value larger than memory.
- `network_disabled` - Boolean to disable networking. Defaults to `false`.
- `network_mode` - Sets the networking mode for the container. One of `bridge`, `host`, `container`.
- `network_aliases` - Adds network-scoped alias for the container in form `['alias-1', 'alias-2']`.
- `oom_kill_disable` - Whether to disable OOM Killer for the container or not.
- `oom_score_adj` - Tune container's OOM preferences (-1000 to 1000).
- `open_stdin` - Boolean value, opens stdin. Defaults to `false`.
- `outfile` - The path to write the file when using `:export` action.
- `port` - The port configuration to use in the container. Matches the syntax used by the `docker` CLI tool.
- `privileged` - Boolean to start the container in privileged more. Defaults to `false`
- `publish_all_ports` - Allocates a random host port for all of a container's exposed ports.
- `remove_volumes` - A boolean to clean up "dangling" volumes when removing the last container with a reference to it. Default to `false` to match the Docker CLI behavior.
- `restart_policy` - One of `no`, `on-failure`, `unless-stopped`, or `always`. Use `always` if you want a service container to survive a Dockerhost reboot. Defaults to `no`.
- `restart_maximum_retry_count` - Maximum number of restarts to try when `restart_policy` is `on-failure`. Defaults to an ever increasing delay (double the previous delay, starting at 100mS), to prevent flooding the server.
- `running_wait_time` - Amount of seconds `docker_container` wait to determine if a process is running.
- `runtime` - Runtime to use when running container. Defaults to `runc`.
- `security_opt` - A list of string values to customize labels for MLS systems, such as SELinux.
- `shm_size` - The size of `/dev/shm`. The format is `<number><unit>`, where number must be greater than 0. Unit is optional and can be b (bytes), k (kilobytes), m(megabytes), or g (gigabytes). The default is `64m`.
- `signal` - The signal to send when using the `:kill` action. Defaults to `SIGTERM`.
- `sysctls` - A hash of sysctls to set on the container. Defaults to `{}`.
- `tty` - Boolean value to allocate a pseudo-TTY. Defaults to `false`.
- `user` - A string value specifying the user inside the container.
- `volumes` - An Array of paths inside the container to expose. Does the same thing as the `VOLUME` directive in a Dockerfile, but works on container creation.
- `volumes_from` - A list of volumes to inherit from another container. Specified in the form `<container name>[:<ro|rw>]`
- `volume_driver` - Driver that this container users to mount volumes.
- `working_dir` - A string specifying the working directory for commands to run in.
- `read_timeout` - May need to increase for commits or exports that are slow
- `write_timeout` - May need to increase for commits or exports that are slow
- `kill_after` - Number of seconds to wait before killing the container. Defaults to wait indefinitely; eventually will hit read_timeout limit.
- `timeout` - Seconds to wait for an attached container to return
- `tls` - Use TLS; implied by --tlsverify. Defaults to ENV['DOCKER_TLS'] if set
- `tls_verify` - Use TLS and verify the remote. Defaults to ENV['DOCKER_TLS_VERIFY'] if set
- `tls_ca_cert` - Trust certs signed only by this CA. Defaults to ENV['DOCKER_CERT_PATH'] if set
- `tls_client_cert` - Path to TLS certificate file for docker cli. Defaults to ENV['DOCKER_CERT_PATH'] if set
- `tls_client_key` - Path to TLS key file for docker cli. Defaults to ENV['DOCKER_CERT_PATH'] if set
- `userns_mode` - Modify the user namespace mode - Defaults to `nil`, example option: `host`
- `pid_mode` - Set the PID (Process) Namespace mode for the container. `host`: use the host's PID namespace inside the container.
- `ipc_mode` - Set the IPC mode for the container - Defaults to `nil`, example option: `host`
- `uts_mode` - Set the UTS namespace mode for the container. The UTS namespace is for setting the hostname and the domain that is visible to running processes in that namespace. By default, all containers, including those with `--network=host`, have their own UTS namespace. The host setting will result in the container using the same UTS namespace as the host. Note that --hostname is invalid in host UTS mode.
- `ro_rootfs` - Mount the container's root filesystem as read only using the `--read-only` flag. Defaults to `false`

## Examples

### Create a container without starting it

```ruby
docker_container 'hello-world' do
  command '/hello'
  action :create
end
```

### Run a command on every Chef Infra Client run

This will exit succesfully. It will happen on every chef-client run

```ruby
docker_container 'busybox_ls' do
  repo 'busybox'
  command 'ls -la /'
  action :run
end
```

The :run action contains both :create and :start the container in one action. Redeploys the container on resource change. It is the default action

### Set environment variables in a container

```ruby
docker_container 'env' do
  repo 'debian'
  env ['PATH=/usr/bin', 'FOO=bar']
  command 'env'
  action :run
end
```

```ruby
docker_container 'env_files' do
  repo 'debian'
  env_file lazy { ['/env_file1', '/env_file2'] }
  command 'env'
  action :run
end
```

### This process remains running between chef-client runs, :run will do nothing on subsequent converges

```ruby
docker_container 'an_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7:7'
  action :run
end
```

### Let docker pick the host port

```ruby
docker_container 'another_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7 -e /bin/cat'
  port '7'
  action :run
end
```

### Specify the udp protocol

```ruby
docker_container 'an_udp_echo_server' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ul -p 7 -e /bin/cat'
  port '5007:7/udp'
  action :run
end
```

### Kill a container

```ruby
docker_container 'bill' do
  action :kill
end
```

### Stop a container

```ruby
docker_container 'hammer_time' do
  action :stop
end
```

### Force-stop a container after 30 seconds

```ruby
docker_container 'hammer_time' do
  kill_after 30
  action :stop
end
```

### Pause a container

```ruby
docker_container 'red_light' do
  action :pause
end
```

### Unpause a container

```ruby
docker_container 'green_light' do
  action :unpause
end
```

### Restart a container

```ruby
docker_container 'restarter' do
  action :restart
end
```

### Delete a container

```ruby
docker_container 'deleteme' do
  remove_volumes true
  action :delete
end
```

### Redeploy a container

```ruby
docker_container 'redeployer' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 7777 -e /bin/cat'
  port '7'
  action :run
end

execute 'redeploy redeployer' do
  notifies :redeploy, 'docker_container[redeployer]', :immediately
  action :run
end
```

### Bind mount local directories

```ruby
docker_container 'bind_mounter' do
  repo 'busybox'
  command 'ls -la /bits /more-bits'
  volumes ['/hostbits:/bits', '/more-hostbits:/more-bits']
  action :run_if_missing
end
```

### Mount volumes from another container

```ruby
docker_container 'chef_container' do
  command 'true'
  volumes '/opt/chef'
  action :create
end

docker_container 'ohai_debian' do
  command '/opt/chef/embedded/bin/ohai platform'
  repo 'debian'
  volumes_from 'chef_container'
end
```

### Set a container's entrypoint

```ruby
docker_container 'ohai_again_debian' do
  repo 'debian'
  volumes_from 'chef_container'
  entrypoint '/opt/chef/embedded/bin/ohai'
  command 'platform'
  action :run_if_missing
end
```

### Automatically remove a container after it exits

```ruby
docker_container 'sean_was_here' do
  command "touch /opt/chef/sean_was_here-#{Time.new.strftime('%Y%m%d%H%M')}"
  repo 'debian'
  volumes_from 'chef_container'
  autoremove true
  action :run
end
```

### Grant NET_ADMIN rights to a container

```ruby
docker_container 'cap_add_net_admin' do
  repo 'debian'
  command 'bash -c "ip addr add 10.9.8.7/24 brd + dev eth0 label eth0:0 ; ip addr list"'
  cap_add 'NET_ADMIN'
  action :run_if_missing
end
```

### Revoke MKNOD rights to a container

```ruby
docker_container 'cap_drop_mknod' do
  repo 'debian'
  command 'bash -c "mknod -m 444 /dev/urandom2 c 1 9 ; ls -la /dev/urandom2"'
  cap_drop 'MKNOD'
  action :run_if_missing
end
```

### Set a container's hostname and domainname

```ruby
docker_container 'fqdn' do
  repo 'debian'
  command 'hostname -f'
  host_name 'computers'
  domain_name 'biz'
  action :run_if_missing
end
```

### Set a container's DNS resolution

```ruby
docker_container 'dns' do
  repo 'debian'
  command 'cat /etc/resolv.conf'
  host_name 'computers'
  dns ['4.3.2.1', '1.2.3.4']
  dns_search ['computers.biz', 'chef.io']
  action :run_if_missing
end
```

### Add extra hosts to a container's `/etc/hosts`

```ruby
docker_container 'extra_hosts' do
  repo 'debian'
  command 'cat /etc/hosts'
  extra_hosts ['east:4.3.2.1', 'west:1.2.3.4']
  action :run_if_missing
end
```

### Manage container's restart_policy

```ruby
docker_container 'try_try_again' do
  repo 'alpine'
  tag '3.1'
  command 'grep asdasdasd /etc/passwd'
  restart_policy 'on-failure'
  restart_maximum_retry_count 2
  action :run_if_missing
end

docker_container 'reboot_survivor' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 123 -e /bin/cat'
  port '123'
  restart_policy 'always'
  action :run_if_missing
end
```

### Manage container links

```ruby
docker_container 'link_source' do
  repo 'alpine'
  tag '3.1'
  env ['FOO=bar', 'BIZ=baz']
  command 'nc -ll -p 321 -e /bin/cat'
  port '321'
  action :run_if_missing
end

docker_container 'link_target_1' do
  repo 'alpine'
  tag '3.1'
  env ['ASD=asd']
  command 'ping -c 1 hello'
  links ['link_source:hello']
  action :run_if_missing
end

docker_container 'link_target_2' do
  repo 'alpine'
  tag '3.1'
  command 'env'
  links ['link_source:hello']
  action :run_if_missing
end

execute 'redeploy_link_source' do
  command 'touch /marker_container_redeploy_link_source'
  creates '/marker_container_redeploy_link_source'
  notifies :redeploy, 'docker_container[link_source]', :immediately
  notifies :redeploy, 'docker_container[link_target_1]', :immediately
  notifies :redeploy, 'docker_container[link_target_2]', :immediately
  action :run
end
```

### Mutate a container between chef-client runs

```ruby
docker_tag 'mutator_from_busybox' do
  target_repo 'busybox'
  target_tag 'latest'
  to_repo 'someara/mutator'
  target_tag 'latest'
end

docker_container 'mutator' do
  repo 'someara/mutator'
  tag 'latest'
  command "sh -c 'touch /mutator-`date +\"%Y-%m-%d_%H-%M-%S\"`'"
  outfile '/mutator.tar'
  force true
  action :run_if_missing
end

execute 'commit mutator' do
  command 'true'
  notifies :commit, 'docker_container[mutator]', :immediately
  notifies :export, 'docker_container[mutator]', :immediately
  notifies :redeploy, 'docker_container[mutator]', :immediately
  action :run
end
```

### Specify read/write timeouts

```ruby
docker_container 'api_timeouts' do
  repo 'alpine'
  read_timeout 60
  write_timeout 60
end
```

### Specify a custom logging driver and its options

```ruby
docker_container 'syslogger' do
  repo 'alpine'
  tag '3.1'
  command 'nc -ll -p 780 -e /bin/cat'
  log_driver 'syslog'
  log_opts 'tag=container-syslogger'
end
```

### Connect to an external docker daemon and create a container

```ruby
docker_container 'external_daemon' do
  repo 'alpine'
  host 'tcp://1.2.3.4:2376'
  action :create
end
```

### Run a container with health_check options

```ruby
docker_container 'health_check' do
  repo 'alpine'
  tag '3.1'
  health_check ({
    "Test" =>
      [
        "string"
      ],
      "Interval" => 0,
      "Timeout" => 0,
      "Retries" => 0,
      "StartPeriod" => 0
  })
  action :run
end
```

### Run a container with a device attached

```ruby
docker_container 'health_check' do
  repo 'alpine'
  tag '3.1'
  devices [{"PathOnHost" => "/dev/dri", "PathInContainer" => "/dev/dri", "CgroupPermissions" => "rwm"}]
  action :run
end
```
