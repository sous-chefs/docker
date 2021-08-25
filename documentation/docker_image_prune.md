# docker_image_prune

The `docker_image_prune` is responsible for pruning Docker images from the system. It speaks directly to the [Docker Engine API](https://docs.docker.com/engine/api/v1.35/#operation/ImagePrune).
Note - this is best implemented by subscribing to `docker_image` changes.  There is no need to to clean up old images upon each converge.  It is best done at the end of a chef run (delayed) only if a new image was pulled.

## Actions

- `:prune` - Delete unused images

## Properties

The `docker_image_prune` resource properties map to filters

- `dangling` - When set to true (or 1), prune only unused and untagged images. When set to false (or 0), all unused images are pruned
- `prune_until` - Prune images created before this timestamp. The `<timestamp>` can be Unix timestamps, date formatted timestamps, or Go duration strings (e.g. 10m, 1h30m) computed relative to the daemon machine’s time.
- `with_label/without_label` -  (`label=<key>`, `label=<key>=<value>`, `label!=<key>`, or `label!=<key>=<value>`) Prune images with (or without, in case label!=... is used) the specified labels.
- `host` - A string containing the host the API should communicate with. Defaults to `ENV['DOCKER_HOST']` if set.

## Examples

- default action, default properties

```ruby
docker_image_prune 'prune-old-images'
```

- All filters

```ruby
docker_image_prune "prune-old-images" do
  dangling true
  prune_until '1h30m'
  with_label 'com.example.vendor=ACME'
  without_label 'no_prune'
  action :prune
end
```
