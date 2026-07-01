# AGENTS.md

## Cookbook Purpose

Provides docker_service, docker_image, and docker_container resources

## Agent Findings

* This cookbook is in an incremental modernization pass. Preserve existing public recipes and attributes unless a later full migration is explicitly selected.
* Dependency management should use `Policyfile.rb`; do not reintroduce Berkshelf.

## Known Limitations

## Supported Platforms

This cookbook supports the following platforms:

* Amazon Linux 2023
* AlmaLinux 9/10
* CentOS Stream 9/10
* Debian 12/13
* Fedora
* Oracle Linux 8/9
* Rocky Linux 9/10
* Red Hat Enterprise Linux 8/9/10
* Ubuntu 22.04/24.04

## Supported Architectures

* x86_64
* aarch64 (arm64)
* armv7l (armhf)
* ppc64le (ppc64el)
* s390x (IBM Z)

## Requirements

* Chef Infra Client 16.0 or later
* `docker-api` gem

## Docker Engine Platform Notes

* Docker publishes installation procedures for CentOS Stream, Debian, Fedora, RHEL, Ubuntu, and
  static binaries.
* Official Docker packages support Ubuntu 22.04/24.04 LTS, Debian 12/13, CentOS Stream 9/10,
  Fedora current releases, and RHEL 8/9/10.
* Derivative distributions may work through the matching upstream package repositories, but Docker
  does not test or verify every derivative.

## Docker Engine Compatibility

* Docker Engine 23.0 removed the classic `--cluster-store`, `--cluster-advertise`, and
  `--cluster-store-opt` daemon flags. The `docker_service` resource ignores the corresponding
  properties when managing Docker 23.0 or later.
