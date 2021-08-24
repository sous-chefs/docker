# docker_registry

The `docker_registry` resource is responsible for managing the connection auth information to a Docker registry.

## Actions

- `:login` - Login to the Docker Registry

## Properties

- `email`
- `password`
- `serveraddress`
- `username`

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
