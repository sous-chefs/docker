# Docker Cookbook Limitations

## Supported Platforms

This cookbook supports the following platforms:

- Amazon Linux 2023
- AlmaLinux 9/10
- CentOS Stream 9/10
- Debian 12/13
- Fedora
- Oracle Linux 8/9
- Rocky Linux 9/10
- Red Hat Enterprise Linux 8/9
- Ubuntu 22.04/24.04

## Supported Architectures

- x86_64
- aarch64 (arm64)
- armv7l (armhf)
- ppc64le (ppc64el)
- s390x (IBM Z)

## Requirements

- Chef Infra Client 16.0 or later
- `docker-api` gem

## Docker Engine Compatibility

- Docker Engine 23.0 removed the classic `--cluster-store`, `--cluster-advertise`, and
  `--cluster-store-opt` daemon flags. The `docker_service` resource ignores the corresponding
  properties when managing Docker 23.0 or later.
