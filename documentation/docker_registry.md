# docker_registry

The `docker_registry` resource is responsible for managing the connection auth information to a Docker registry.

## Actions

- `:login` - Login to the Docker Registry

## Properties

- `email`
- `password`
- `serveraddress`
- `username`
- `repository_prefix` - Optional repository path prefix relative to `serveraddress`, such as `team` or `team/production`. Omit it to register the default credentials for the registry.

## Examples

- Log into or register with public registry:

```ruby
docker_registry 'https://index.docker.io/v1/' do
  username 'publicme'
  password 'hope_this_is_in_encrypted_databag'
  email 'publicme@computers.biz'
end
```

Log into private registry with optional port:

```ruby
docker_registry 'my local registry' do
   serveraddress 'https://registry.computers.biz:8443/'
   username 'privateme'
   password 'still_hope_this_is_in_encrypted_databag'
   email 'privateme@computers.biz'
end
```

Register separate credentials for a repository namespace using a distinct resource name and an explicit registry address with a qualified hostname, a port, or `localhost`.
Declare the login before the `docker_image` resources that use it.

```ruby
docker_registry 'production registry login' do
  serveraddress 'https://registry.computers.biz:8443/'
  repository_prefix 'team/production'
  username 'production-user'
  password lazy { node.run_state.fetch('production_registry_password') }
end

docker_image 'registry.computers.biz:8443/team/production/application'
```

Pulls and pushes use the longest matching prefix made up of complete path segments.
Other repositories on the same host use the default credentials if registered, or anonymous access.
For repository prefixes, Docker Hub names use the same paths with either `docker.io` or `index.docker.io`. Use `library` for official images such as `alpine`.
