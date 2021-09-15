
# docker_volume

The `docker_volume` resource is responsible for managing Docker named volumes.

## Actions

- `:create` - create a volume
- `:remove` - remove a volume

## Properties

- `driver` - Name of the volume driver to use. Only used for `:create`.
- `host`
- `opts` - Options to pass to the volume driver. Only used for `:create`.
- `volume`
- `volume_name` - Name of the volume to operate on (defaults to the resource name).

## Examples

Create a volume named 'hello'

```ruby
docker_volume 'hello' do
  action :create
end

docker_container 'file_writer' do
  repo 'alpine'
  tag '3.1'
  volumes 'hello:/hello'
  command 'touch /hello/sean_was_here'
  action :run_if_missing
end
```
