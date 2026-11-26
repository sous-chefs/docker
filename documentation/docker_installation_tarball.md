# docker_installation_tarball

The `docker_installation_tarball` resource installs Docker on a system using pre-compiled binary tarballs from the official Docker downloads.

## Actions

- `:create` - Downloads and installs Docker from a tarball
- `:delete` - Removes Docker installed from a tarball

## Properties

| Property   | Type   | Default          | Description                           |
|------------|--------|------------------|---------------------------------------|
| `checksum` | String | Based on version | SHA256 checksum of the Docker tarball |
| `source`   | String | Based on version | URL of the Docker tarball             |
| `channel`  | String | `'stable'`       | Docker release channel to use         |
| `version`  | String | `'20.10.11'`     | Docker version to install             |

## Examples

### Install Default Version

```ruby
docker_installation_tarball 'default' do
  action :create
end
```

### Install Specific Version

```ruby
docker_installation_tarball 'default' do
  version '19.03.15'
  action :create
end
```

### Install from Custom Source

```ruby
docker_installation_tarball 'default' do
  source 'https://example.com/docker-20.10.11.tgz'
  checksum 'dd6ff72df1edfd61ae55feaa4aadb88634161f0aa06dbaaf291d1be594099ff3'
  action :create
end
```

### Remove Docker Installation

```ruby
docker_installation_tarball 'default' do
  action :delete
end
```

## Platform Support

This resource supports the following platforms:

### Linux

- Version 18.03.1: checksum `0e245c42de8a21799ab11179a4fce43b494ce173a8a2d6567ea6825d6c5265aa`
- Version 18.06.3: checksum `346f9394393ee8db5f8bd1e229ee9d90e5b36931bdd754308b2ae68884dd6822`
- Version 18.09.9: checksum `82a362af7689038c51573e0fd0554da8703f0d06f4dfe95dd5bda5acf0ae45fb`
- Version 19.03.15: checksum `5504d190eef37355231325c176686d51ade6e0cabe2da526d561a38d8611506f`
- Version 20.10.11: checksum `dd6ff72df1edfd61ae55feaa4aadb88634161f0aa06dbaaf291d1be594099ff3`

### Darwin (macOS)

- Version 18.03.1: checksum `bbfb9c599a4fdb45523496c2ead191056ff43d6be90cf0e348421dd56bc3dcf0`
- Version 18.06.3: checksum `f7347ef27db9a438b05b8f82cd4c017af5693fe26202d9b3babf750df3e05e0c`
- Version 18.09.9: checksum `ed83a3d51fef2bbcdb19d091ff0690a233aed4bbb47d2f7860d377196e0143a0`
- Version 19.03.15: checksum `61672045675798b2075d4790665b74336c03b6d6084036ef22720af60614e50d`
- Version 20.10.11: checksum `8f338ba618438fa186d1fa4eae32376cca58f86df2b40b5027c193202fad2acf`

## Notes

- The resource automatically detects the system architecture and kernel type to download the appropriate tarball
- Requires `tar` package to be installed (the resource will install it if missing)
- Creates a `docker` system group
- Filename format varies based on Docker version:
  - For versions >= 19.x.x: `docker-VERSION.tgz`
  - For version 18.09.x: `docker-VERSION.tgz`
  - For versions <= 18.06.x: `docker-VERSION-ce.tgz`
