
# docker_tag

Docker tags work very much like hard links in a Unix filesystem. They are just references to an existing image. Therefore, the docker_tag resource has taken inspiration from the Chef `link` resource.

## Actions

- `:tag` - Tags the image

## Properties

- `target_repo` - The repo half of the source image identifier.
- `target_tag` - The tag half of the source image identifier.
- `to_repo` - The repo half of the new image identifier
- `to_tag`- The tag half of the new image identifier

## Examples

```ruby
docker_tag 'private repo tag for hello-again:1.0.1' do
  target_repo 'hello-again'
  target_tag 'v0.1.0'
  to_repo 'localhost:5043/someara/hello-again'
  to_tag 'latest'
  action :tag
end
```
