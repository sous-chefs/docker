# docker_installation_package

The `docker_installation_package` resource is responsible for installing Docker via package manager. It supports both Debian/Ubuntu and RHEL/Fedora platforms.

## Actions

- `:create` - Installs Docker package and sets up the Docker repository if enabled
- `:delete` - Removes the Docker package

## Properties

| Property            | Type    | Default                 | Description                                             |
|---------------------|---------|-------------------------|---------------------------------------------------------|
| `setup_docker_repo` | Boolean | `true`                  | Whether to set up the Docker repository                 |
| `repo_channel`      | String  | `'stable'`              | Repository channel to use (`stable`, `test`, `nightly`) |
| `package_name`      | String  | `'docker-ce'`           | Name of the Docker package to install                   |
| `package_version`   | String  | `nil`                   | Specific package version to install                     |
| `version`           | String  | `nil`                   | Docker version to install (e.g., '20.10.23')            |
| `package_options`   | String  | `nil`                   | Additional options to pass to the package manager       |
| `site_url`          | String  | `'download.docker.com'` | Docker repository URL                                   |

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
