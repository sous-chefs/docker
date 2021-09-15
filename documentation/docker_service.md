# docker_service

The `docker_service`: resource is a composite resource that uses `docker_installation` and `docker_service_manager` resources.

- The `:create` action uses a `docker_installation`
- The `:delete` action uses a `docker_installation`
- The `:start` action uses a `docker_service_manager`
- The `:stop` action uses a `docker_service_manager`

The service management strategy for the host platform is dynamically chosen based on platform, but can be overridden.

## Example

```ruby
docker_service 'tls_test:2376' do
  host [ "tcp://#{node['ipaddress']}:2376", 'unix:///var/run/docker.sock' ]
  tls_verify true
  tls_ca_cert '/path/to/ca.pem'
  tls_server_cert '/path/to/server.pem'
  tls_server_key '/path/to/server-key.pem'
  tls_client_cert '/path/to/client.pem'
  tls_client_key '/path/to/client-key.pem'
  action [:create, :start]
end
```

WARNING - When creating multiple `docker_service` resources on the same machine, you will need to specify unique data_root properties to avoid unexpected behavior and possible data corruption.

## Properties

The `docker_service` resource property list mostly corresponds to the options found in the [Docker Command Line Reference](https://docs.docker.com/engine/reference/commandline/docker/)

- `api_cors_header` - Set CORS headers in the remote API
- `auto_restart`
- `exec_opts`
- `bip` - Specify network bridge IP
- `bridge` - Attach containers to a network bridge
- `checksum` - sha256 checksum of Docker binary
- `cluster_advertise` - IP and port that this daemon should advertise to the cluster
- `cluster_store_opts` - Cluster store options
- `cluster_store` - Cluster store to use
- `daemon` - Enable daemon mode
- `data_root` - Root of the Docker runtime
- `debug` - Enable debug mode
- `default_ip_address_pool` - Set the default address pool for networks creates by docker
- `default_ulimit` - Set default ulimit settings for containers
- `disable_legacy_registry` - Do not contact legacy registries
- `dns_search` - DNS search domains to use
- `dns` - DNS server(s) to use
- `exec_driver` - Exec driver to use
- `fixed_cidr_v6` - IPv6 subnet for fixed IPs
- `fixed_cidr` - IPv4 subnet for fixed IPs
- `group` - Posix group for the unix socket. Default to `docker`
- `host` - Daemon socket(s) to connect to - `tcp://host:port`, `unix:///path/to/socket`, `fd://*` or `fd://socketfd`
- `http_proxy` - ENV variable set before for Docker daemon starts
- `https_proxy` - ENV variable set before for Docker daemon starts
- `icc` - Enable inter-container communication
- `insecure_registry` - Enable insecure registry communication
- `install_method` - Select script, package, tarball, none, or auto. Defaults to `auto`.
- `instance`- Optional property used to override the name provided in the resource.
- `ip_forward` - Enable ip forwarding
- `ip_masq` - Enable IP masquerading
- `ip` - Default IP when binding container ports
- `iptables` - Enable addition of iptables rules
- `ipv4_forward` - Enable net.ipv4.ip_forward
- `ipv6_forward` - Enable net.ipv6.ip_forward
- `ipv6` - Enable IPv6 networking
- `labels` A string or array to set metadata on the daemon in the form ['foo:bar', 'hello:world']`
- `log_driver` - Container's logging driver (json-file/syslog/journald/gelf/fluentd/awslogs/splunk/etwlogs/gcplogs/logentries/loki-docker/local/none)
- `log_level` - Set the logging level
- `log_opts` - Container's logging driver options (driver-specific)
- `logfile` - Location of Docker daemon log file
- `mount_flags` - Set the systemd mount propagation flag.
- `mtu` - Set the containers network MTU
- `no_proxy` - ENV variable set before for Docker daemon starts
- `package_name` - Set the package name. Defaults to `docker-ce`
- `pidfile` - Path to use for daemon PID file
- `registry_mirror` - A string or array to set the preferred Docker registry mirror(s)
- `selinux_enabled` - Enable selinux support
- `source` - URL to the pre-compiled Docker binary used for installation. Defaults to a calculated URL based on kernel version, Docker version, and platform arch. By default, this will try to get to "<http://get.docker.io/builds/>".
- `storage_driver` - Storage driver to use
- `storage_opts` - Set storage driver options
- `tls_ca_cert` - Trust certs signed only by this CA. Defaults to ENV['DOCKER_CERT_PATH'] if set
- `tls_client_cert` - Path to TLS certificate file for docker cli. Defaults to ENV['DOCKER_CERT_PATH'] if set
- `tls_client_key` - Path to TLS key file for docker cli. Defaults to ENV['DOCKER_CERT_PATH'] if set
- `tls_server_cert` - Path to TLS certificate file for docker service
- `tls_server_key` - Path to TLS key file for docker service
- `tls_verify` - Use TLS and verify the remote. Defaults to ENV['DOCKER_TLS_VERIFY'] if set
- `tls` - Use TLS; implied by --tlsverify. Defaults to ENV['DOCKER_TLS'] if set
- `tmpdir` - ENV variable set before for Docker daemon starts
- `userland_proxy`- Enables or disables docker-proxy
- `userns_remap` - Enable user namespace remapping options - `default`, `uid`, `uid:gid`, `username`, `username:groupname` (see: [Docker User Namespaces](see: https://docs.docker.com/v1.10/engine/reference/commandline/daemon/#daemon-user-namespace-options))
- `live_restore` - Keep containers alive during daemon downtime (see: [Live restore](https://docs.docker.com/config/containers/live-restore))
- `version` - Docker version to install

### Miscellaneous Options

- `misc_opts` - Pass the docker daemon any other options bypassing flag validation, supplied as `--flag=value`

### Systemd-specific Options

- `systemd_opts` - An array of strings that will be included as individual lines in the systemd service unit for Docker. _Note_: This option is only relevant for systems where systemd is the default service manager or where systemd is specified explicitly as the service manager.
- `systemd_socket_opts` - An array of strings that will be included as individual lines in the systemd socket unit for Docker. _Note_: This option is only relevant for systems where systemd is the default service manager or where systemd is specified explicitly as the service manager.

## Actions

- `:create` - Lays the Docker bits out on disk
- `:delete` - Removes the Docker bits from the disk
- `:start` - Makes sure the service provider is set up properly and start it
- `:stop` - Stops the service
- `:restart` - Restarts the service

## `docker_service` implementations

- `docker_service_execute` - The simplest docker_service. Just starts a process. Fire and forget.
- `docker_service_sysvinit` - Uses a SystemV init script to manage the service state.
- `docker_service_systemd` - Uses an Systemd unit file to manage the service state. NOTE: This does NOT enable systemd socket activation.
