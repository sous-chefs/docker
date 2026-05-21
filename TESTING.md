# Testing

Please refer to [the community cookbook documentation on testing](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/main/TESTING.MD).

## Kitchen Driver Strategy

This cookbook validates Docker Engine service behavior and Docker daemon resources. Local testing
uses Vagrant via `kitchen.yml`, while GitHub Actions uses the Exec driver in `kitchen.exec.yml`
against the runner's host Docker environment. Dokken is intentionally not configured because these
suites need host-level Docker service access rather than a nested container daemon.
