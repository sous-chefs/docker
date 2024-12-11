# docker_volume_prune

The `docker_volume_prune` resource removes all unused Docker volumes. Volumes that are still referenced by at least one container are not removed.

## Actions

- `:prune` - Remove unused Docker volumes

## Properties

| Property        | Type    | Default              | Description                                       |
|-----------------|---------|----------------------|---------------------------------------------------|
| `without_label` | String  | `nil`                | Only remove volumes without the specified label   |
| `with_label`    | String  | `nil`                | Only remove volumes with the specified label      |
| `read_timeout`  | Integer | `120`                | HTTP read timeout for Docker API calls            |
| `host`          | String  | `ENV['DOCKER_HOST']` | Docker daemon socket to connect to                |
| `all`           | Boolean | `false`              | Remove all unused volumes, not just dangling ones |

## Examples

### Basic Usage - Remove Unused Volumes

```ruby
docker_volume_prune 'prune' do
  action :prune
end
```

### Remove All Unused Volumes

```ruby
docker_volume_prune 'prune_all' do
  all true
  action :prune
end
```

### Remove Volumes with Specific Label

```ruby
docker_volume_prune 'prune_labeled' do
  with_label 'environment=test'
  action :prune
end
```

### Remove Volumes Without Specific Label

```ruby
docker_volume_prune 'prune_without_label' do
  without_label 'environment=production'
  action :prune
end
```

### Custom Docker Host

```ruby
docker_volume_prune 'prune' do
  host 'tcp://127.0.0.1:2375'
  action :prune
end
```

## Notes

- Uses Docker Engine API v1.42
- The prune operation removes all unused volumes that are not referenced by any containers
- The operation is irreversible - once a volume is pruned, its data cannot be recovered
- The resource logs the result of the prune operation
- The `read_timeout` property can be adjusted if the operation takes longer than expected
- Label filters can be used to selectively prune volumes based on their metadata

## Platform Support

This resource is supported on any platform that can run the Docker daemon.
