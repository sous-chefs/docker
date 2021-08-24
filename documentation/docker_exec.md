# docker_exec

The `docker_exec` resource allows you to execute commands inside of a running container.

## Actions

- `:run` - Runs the command

## Properties

- `host` - Daemon socket(s) to connect to - `tcp://host:port`, `unix:///path/to/socket`, `fd://*` or `fd://socketfd`.
- `command` - A command structured as an Array similar to `CMD` in a Dockerfile.
- `container` - Name of the container to execute the command in.
- `timeout`- Seconds to wait for an attached container to return. Defaults to 60 seconds.
- `container_obj`

## Examples

```ruby
docker_exec 'touch_it' do
  container 'busybox_exec'
  command ['touch', '/tmp/onefile']
end
```
