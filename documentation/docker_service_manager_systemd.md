# docker_service_manager_systemd

The `docker_service_manager_systemd` resource manages the Docker daemon using systemd. This is the preferred way to manage Docker on systems that use systemd as their init system.

## Actions

- `:start` - Starts and enables the Docker daemon
- `:stop` - Stops and disables the Docker daemon
- `:restart` - Restarts the Docker daemon (stop followed by start)

## Properties

This resource inherits properties from the `docker_service_base` resource. Common properties include:

| Property              | Type    | Default    | Description                                 |
|-----------------------|---------|------------|---------------------------------------------|
| `docker_daemon_cmd`   | String  | Generated  | Command to start the Docker daemon          |
| `docker_name`         | String  | `'docker'` | Name of the Docker service                  |
| `connect_socket`      | String  | `nil`      | Docker socket path                          |
| `docker_containerd`   | Boolean | -          | Whether to use containerd                   |
| `env_vars`            | Hash    | `{}`       | Environment variables for the Docker daemon |
| `systemd_socket_args` | Hash    | `{}`       | Additional systemd socket arguments         |
| `systemd_args`        | Hash    | `{}`       | Additional systemd service arguments        |

## Examples

### Basic Usage

```ruby
docker_service_manager_systemd 'default' do
  action :start
end
```

### Custom Service Configuration

```ruby
docker_service_manager_systemd 'default' do
  systemd_args({
    'TimeoutStartSec' => '0',
    'ExecStartPost' => '/usr/bin/sleep 1'
  })
  env_vars({
    'HTTP_PROXY' => 'http://proxy.example.com:3128',
    'NO_PROXY' => 'localhost,127.0.0.1'
  })
  action :start
end
```

### Using Custom Socket

```ruby
docker_service_manager_systemd 'default' do
  connect_socket 'unix:///var/run/custom-docker.sock'
  action :start
end
```

### Stop Docker Service

```ruby
docker_service_manager_systemd 'default' do
  action :stop
end
```

## Files Created/Modified

The resource manages the following files:

- `/lib/systemd/system/[docker_name].socket` - Main systemd socket file
- `/etc/systemd/system/[docker_name].socket` - Socket override file
- `/lib/systemd/system/[docker_name].service` - Main systemd service file
- `/etc/systemd/system/[docker_name].service` - Service override file
- `/etc/containerd/config.toml` - Containerd configuration
- `/etc/systemd/system/containerd.service` - Containerd service file (if enabled)

## Notes

- This resource is only available on Linux systems using systemd
- Automatically creates and manages containerd configuration when needed
- Supports both socket activation and direct service management
- Handles systemd daemon-reload automatically when configurations change
- Includes retry logic for service start operations
- Creates a wait-ready script to ensure Docker is fully operational
- Supports custom environment variables and systemd unit options
- Can be used with custom Docker socket paths
- Manages both the Docker service and its associated socket unit

## Platform Support

This resource is supported on Linux distributions that use systemd as their init system, including:

- Recent versions of Ubuntu (16.04+)
- Recent versions of Debian (8+)
- Recent versions of CentOS/RHEL (7+)
- Recent versions of Fedora
