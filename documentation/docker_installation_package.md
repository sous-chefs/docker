# docker_installation_package

The `docker_installation_package` resource is responsible for installing Docker via package manager. It supports both Debian/Ubuntu and RHEL/Fedora platforms.

## Actions

- `:create` - Installs Docker package and sets up the Docker repository if enabled
- `:delete` - Removes the Docker package

## Properties

| Property            | Type             | Default                 | Description                                             |
|---------------------|------------------|-------------------------|---------------------------------------------------------|
| `setup_docker_repo` | Boolean          | `true`                  | Whether to set up the Docker repository                 |
| `repo_channel`      | String           | `'stable'`              | Repository channel to use (`stable`, `test`, `nightly`) |
| `package_name`      | String           | `'docker-ce'`           | Name of the Docker package to install                   |
| `package_version`   | String           | `nil`                   | Specific package version to install                     |
| `version`           | String           | `nil`                   | Docker version to install (e.g., '20.10.23')            |
| `package_options`   | String           | `nil`                   | Additional options to pass to the package manager       |
| `site_url`          | String           | `'download.docker.com'` | Docker repository URL                                   |
| `restart_target`    | `Chef::Resource` | `nil`                   | Internal property set automatically by `docker_service` |

### How Package-Triggered Restarts Work

Use `docker_service` when this cookbook should install Docker and manage its
service:

```ruby
docker_service 'default' do
  install_method 'package'
  action [:create, :start]
end
```

The `docker_service` resource creates the package-installation resource and
passes itself as that resource's `restart_target`. In plain English, it tells
the package installer: "If you change the Docker package, notify this Docker
service resource."

The relevant internal code is equivalent to:

```ruby
service_to_restart = new_resource

docker_installation_package 'default' do
  restart_target service_to_restart
end
```

Passing the object does **not** restart Docker. It only identifies which Chef
resource should receive a future notification. The package resource decides
whether to send that notification. Think of `restart_target` as an address:
passing the address does not send a message; it tells Chef where to deliver the
message if the package changes.

The package resource uses that address here:

```ruby
package 'docker-ce' do
  notifies :restart, restart_target, :immediately
end
```

Chef sends a resource's notifications only when that resource updates the
system. The results are therefore:

- A Docker package install or upgrade restarts Docker immediately.
- A Chef run where the Docker package is already correct does not restart
  Docker.
- A repository or package-cache update without a package change does not restart
  Docker.

If you call `docker_installation_package` directly, it only manages the package;
it does not manage or restart the Docker service.

`restart_target` implements the handoff between these two resources. It is set
automatically by `docker_service` and should not be set in a recipe.

### Applying This Pattern Elsewhere

This pattern is useful when a higher-level resource coordinates separate
install, configuration, and service resources:

```ruby
service_target = new_resource

application_install 'example' do
  restart_target service_target
end

application_config 'example' do
  reload_target service_target
end
```

The lower-level resources place notifications on the changes that require them:

```ruby
package 'example' do
  notifies :restart, restart_target, :immediately
end

template '/etc/example.conf' do
  notifies :reload, reload_target, :delayed
end
```

This keeps the responsibilities separate:

- The install resource knows which package changes require a restart.
- The configuration resource knows which file changes require a reload or
  restart.
- The service resource owns the `:start`, `:stop`, `:reload`, and `:restart`
  actions.
- The higher-level resource connects them by passing the service resource as the
  notification target.

These generic examples illustrate the reusable pattern. The Docker cookbook
currently uses it only for package-triggered restarts.

## Examples

### Install Latest Version of Docker

```ruby
docker_installation_package 'default' do
  action :create
end
```

### Install Specific Version of Docker

```ruby
docker_installation_package 'default' do
  version '20.10.23'
  action :create
end
```

### Install from Test Channel

```ruby
docker_installation_package 'default' do
  repo_channel 'test'
  action :create
end
```

### Install Without Setting Up Docker Repository

```ruby
docker_installation_package 'default' do
  setup_docker_repo false
  action :create
end
```

### Remove Docker Installation

```ruby
docker_installation_package 'default' do
  action :delete
end
```

## Platform Support

This resource supports the following platforms:

### Debian/Ubuntu

- Debian 9 (Stretch)
- Debian 10 (Buster)
- Debian 11 (Bullseye)
- Debian 12 (Bookworm)
- Ubuntu 18.04 (Bionic)
- Ubuntu 20.04 (Focal)
- Ubuntu 22.04 (Jammy)
- Ubuntu 24.04 (Noble)

### RHEL/Fedora

- RHEL/CentOS 7 and later
- Fedora (latest versions)

## Notes

- The resource automatically handles architecture-specific package names and repositories
- For Debian/Ubuntu systems, it installs `apt-transport-https` package as a prerequisite
- Version strings are handled differently based on the Docker version and platform:
  - For versions < 18.06: Uses format like `VERSION~ce-0~debian` or `VERSION~ce-0~ubuntu`
  - For versions >= 18.09: Uses format like `5:VERSION~3-0~debian-CODENAME` or `5:VERSION~3-0~ubuntu-CODENAME`
  - For versions >= 23.0 on Ubuntu: Uses format like `5:VERSION-1~ubuntu.VERSION~CODENAME`
