# docker_service

The `docker_service` resource is a composite resource that manages Docker daemon installation and service configuration. It combines the functionality of `docker_installation` and `docker_service_manager` resources.

## Actions

- `:create` - Installs Docker using `docker_installation`
- `:delete` - Removes Docker installation
- `:start` - Starts the Docker daemon using `docker_service_manager`
- `:stop` - Stops the Docker daemon
- `:restart` - Restarts the Docker daemon

The service management strategy is automatically chosen based on the platform but can be overridden.

## Properties

### Installation Properties

- `install_method` - Installation method: `script`, `package`, `tarball`, `none`, or `auto` (default)
- `service_manager` - Service manager to use: `execute`, `systemd`, `none`, or `auto` (default)

#### Script Installation

- `repo` - Repository URL for script installation
- `script_url` - Custom script URL for installation

#### Package Installation

- `package_version` - Specific package version to install
- `package_name` - Package name (default: docker-ce)
- `setup_docker_repo` - Whether to configure Docker repository
- `package_options` - Additional package installation options

#### Tarball Installation

- `checksum` - SHA256 checksum of Docker binary
- `docker_bin` - Path to Docker binary
- `source` - URL to Docker binary tarball
- `version` - Docker version to install

### Core Settings

- `instance` - Resource name (name property)
- `env_vars` - Hash of environment variables for Docker service
- `data_root` - Root directory of the Docker runtime
- `debug` - Enable debug mode (default: false)
- `daemon` - Enable daemon mode (default: true)
- `group` - Posix group for unix socket (default: 'docker')

### Network Configuration

- `bip` - Network bridge IP (accepts IPv4/IPv6 address/CIDR)
- `bridge` - Network bridge for container attachment
- `default_ip_address_pool` - Default address pool for networks
- `dns` - DNS servers (String or Array)
- `dns_search` - DNS search domains (Array)
- `fixed_cidr` - IPv4 subnet for fixed IPs
- `fixed_cidr_v6` - IPv6 subnet for fixed IPs
- `ip` - Default IP for container binding (IPv4/IPv6)
- `ip_forward` - Enable IP forwarding
- `ipv4_forward` - Enable net.ipv4.ip_forward (default: true)
- `ipv6_forward` - Enable net.ipv6.ip_forward (default: true)
- `ip_masq` - Enable IP masquerading
- `iptables` - Enable iptables rules
- `ip6tables` - Enable ip6tables rules
- `ipv6` - Enable IPv6 networking
- `mtu` - Container network MTU

### Cluster Configuration

- `cluster_store` - Cluster store settings
- `cluster_advertise` - Cluster advertisement configuration
- `cluster_store_opts` - Cluster store options (String or Array)

### API and Security

- `api_cors_header` - Set CORS headers for remote API
- `host` - Docker daemon socket(s) to connect to
- `selinux_enabled` - Enable SELinux support
- `userns_remap` - User namespace remapping options
- `labels` - Daemon metadata (String or Array)

### Storage

- `storage_driver` - Storage driver (String or Array)
- `storage_opts` - Storage driver options (Array)
- `exec_driver` - Execution driver ('native', 'lxc', nil)
- `exec_opts` - Execution options (String or Array)

### Logging

- `log_driver` - Container logging driver:
  - Supported: json-file, syslog, journald, gelf, fluentd, awslogs, splunk, etwlogs, gcplogs, logentries, loki-docker, none, local
- `log_opts` - Logging driver options (String or Array)
- `log_level` - Logging level (debug, info, warn, error, fatal)
- `logfile` - Log file location (default: '/var/log/docker.log')

### Process Management

- `pidfile` - PID file location (default: /var/run/[service-name].pid)
- `auto_restart` - Enable automatic restart (default: false)
- `service_timeout` - Docker wait-ready timeout in seconds (default: 20)

### Proxy Settings

- `http_proxy` - HTTP proxy environment variable
- `https_proxy` - HTTPS proxy environment variable
- `no_proxy` - No proxy environment variable
- `tmpdir` - Temporary directory path

### Registry

- `disable_legacy_registry` - Disable legacy registry support
- `insecure_registry` - Enable insecure registry communication
- `registry_mirror` - Preferred registry mirror(s)

### Resource Limits

- `default_ulimit` - Default ulimit settings (String or Array)

### Service Management

#### Systemd Options

- `systemd_opts` - Additional systemd service unit options
- `systemd_socket_opts` - Additional systemd socket unit options
- `mount_flags` - Systemd mount propagation flags

### Advanced Options

- `live_restore` - Keep containers alive during daemon downtime (default: false)
- `userland_proxy` - Enable/disable docker-proxy
- `misc_opts` - Additional daemon options as `--flag=value`

## Examples

### Basic Docker Service

```ruby
docker_service 'default' do
  action [:create, :start]
end
```

### Custom Installation

```ruby
docker_service 'custom' do
  install_method 'package'
  package_version '20.10.11'
  service_manager 'systemd'
  action [:create, :start]
end
```

### Secure Configuration with Registry Mirrors

```ruby
docker_service 'production' do
  registry_mirror ['https://mirror1.example.com', 'https://mirror2.example.com']
  insecure_registry ['172.16.0.0/12']
  storage_driver 'overlay2'
  storage_opts ['overlay2.override_kernel_check=true']
  log_driver 'json-file'
  log_opts ['max-size=100m', 'max-file=3']
  action [:create, :start]
end
```

### Multiple Services

```ruby
docker_service 'primary' do
  data_root '/var/lib/docker-primary'
  action [:create, :start]
end

docker_service 'secondary' do
  data_root '/var/lib/docker-secondary'
  host ['tcp://0.0.0.0:2375']
  action [:create, :start]
end
```

## Warning

When creating multiple `docker_service` resources on the same machine, you MUST specify unique `data_root` properties to avoid data corruption and unexpected behavior.
