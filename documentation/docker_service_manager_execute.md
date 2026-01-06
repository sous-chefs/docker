# docker_service_manager_execute

The `docker_service_manager_execute` resource manages the Docker daemon using Chef's execute resources. This is a basic service manager that uses shell commands to start, stop, and restart the Docker daemon.

## Actions

- `:start` - Starts the Docker daemon
- `:stop` - Stops the Docker daemon
- `:restart` - Restarts the Docker daemon (stop followed by start)

## Properties

This resource inherits properties from the `docker_service_base` resource. Common properties include:

| Property            | Type   | Default       | Description                        |
|---------------------|--------|---------------|------------------------------------|
| `docker_daemon_cmd` | String | Generated     | Command to start the Docker daemon |
| `logfile`           | String | Based on name | Path to the log file               |
| `pidfile`           | String | Based on name | Path to the PID file               |
| `http_proxy`        | String | `nil`         | HTTP proxy settings                |
| `https_proxy`       | String | `nil`         | HTTPS proxy settings               |
| `no_proxy`          | String | `nil`         | No proxy settings                  |
| `tmpdir`            | String | `nil`         | Temporary directory path           |

## Examples

### Basic Usage

```ruby
docker_service_manager_execute 'default' do
  action :start
end
```

### Start Docker with Custom Settings

```ruby
docker_service_manager_execute 'default' do
  http_proxy 'http://proxy.example.com:3128'
  https_proxy 'http://proxy.example.com:3128'
  no_proxy 'localhost,127.0.0.1'
  action :start
end
```

### Stop Docker Service

```ruby
docker_service_manager_execute 'default' do
  action :stop
end
```

### Restart Docker Service

```ruby
docker_service_manager_execute 'default' do
  action :restart
end
```

## Notes

- This resource enables IPv4 and IPv6 forwarding using sysctl
- The Docker daemon is started as a background process using bash
- A wait script is created to ensure the daemon is ready before proceeding
- The stop action uses a timeout of 10 seconds when stopping the daemon
- The resource uses process checking to prevent duplicate daemon instances
- Log output is redirected to the specified logfile
- Environment variables (HTTP_PROXY, HTTPS_PROXY, NO_PROXY, TMPDIR) are passed to the daemon process

## Platform Support

This resource should work on any platform that can run the Docker daemon, but it's primarily tested on Linux systems.
