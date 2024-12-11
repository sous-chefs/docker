# docker_installation_script

The `docker_installation_script` resource installs Docker on Linux systems using the official Docker installation scripts. This is also known as the "curl pipe bash" installation method.

## Actions

- `:create` - Downloads and executes the Docker installation script
- `:delete` - Removes Docker packages installed by the script

## Properties

| Property     | Type   | Default        | Description                                                           |
|-------------|--------|----------------|-----------------------------------------------------------------------|
| `repo`      | String | `'main'`       | Repository to use for installation. One of: `main`, `test`, or `experimental` |
| `script_url`| String | Based on repo  | URL of the installation script. Defaults to official Docker URLs based on the repo property |

## Examples

### Install Docker from Main Repository

```ruby
docker_installation_script 'default' do
  action :create
end
```

### Install Docker from Test Repository

```ruby
docker_installation_script 'default' do
  repo 'test'
  action :create
end
```

### Install Docker from Experimental Repository

```ruby
docker_installation_script 'default' do
  repo 'experimental'
  action :create
end
```

### Install Docker Using Custom Script URL

```ruby
docker_installation_script 'default' do
  script_url 'https://my-custom-docker-install.example.com/install.sh'
  action :create
end
```

### Remove Docker Installation

```ruby
docker_installation_script 'default' do
  action :delete
end
```

## Notes

- This resource is only available on Linux systems
- The installation script requires `curl` to be installed (the resource will install it if missing)
- The script is executed with `sh` shell
- The installation is considered complete when `/usr/bin/docker` exists
- When removing Docker, both `docker-ce` and `docker-engine` packages are removed
- Default script URLs:
  - Main: <https://get.docker.com/>
  - Test: <https://test.docker.com/>

## Platform Support

This resource is supported on all Linux platforms that can run the Docker installation scripts.
