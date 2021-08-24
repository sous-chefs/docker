# docker_image

The `docker_image` is responsible for managing Docker image pulls, builds, and deletions. It speaks directly to the [Docker Engine API](https://docs.docker.com/engine/api/v1.35/#tag/Image).

## Actions

- `:pull` - Pulls an image from the registry. Default action.
- `:pull_if_missing` - Pulls an image from the registry, only if it missing
- `:build` - Builds an image from a Dockerfile, directory, or tarball
- `:build_if_missing` - Same build, but only if it is missing
- `:save` - Exports an image to a tarball at `destination`
- `:import` - Imports an image from a tarball at `destination`
- `:remove` - Removes (untags) an image
- `:push` - Pushes an image to the registry

## Properties

The `docker_image` resource properties mostly corresponds to the [Docker Engine API](https://docs.docker.com/engine/api/v1.35/#tag/Image) as driven by the [docker-api Ruby gem](https://github.com/swipely/docker-api)

A `docker_image`'s full identifier is a string in the form `<repo>:<tag>`. There is some nuance around naming using the
public registry vs a private one.

- `repo` - aka `image_name` - The first half of a Docker image's identity. This is a string in the form: `registry:port/owner/image_name`. If the `registry:port` portion is left off, Docker will implicitly use the Docker public registry. "Official Images" omit the owner part. This means a repo id can be as short as `busybox`, `alpine`, or `centos`. These names refer to official images on the public registry. Names can be as long as `my.computers.biz:5043/what/ever` to refer to custom images on an private registry. Often you'll see something like `chef/chef` to refer to private images on the public registry. - Defaults to resource name.
- `tag` - The second half of a Docker image's identity. - Defaults to `latest`
- `source` - Path to input for the `:import`, `:build` and `:build_if_missing` actions. For building, this can be a Dockerfile, a tarball containing a Dockerfile in its root, or a directory containing a Dockerfile. For `:import`, this should be a tarball containing Docker formatted image, as generated with `:save`.
- `destination` - Path for output from the `:save` action.
- `force` - A force boolean used in various actions - Defaults to false
- `nocache` - Used in `:build` operations. - Defaults to false
- `noprune` - Used in `:remove` operations - Defaults to false
- `rm` - Remove intermediate containers after a successful build (default behavior) - Defaults to `true`
- `read_timeout` - May need to increase for long image builds/pulls
- `write_timeout` - May need to increase for long image builds/pulls
- `host` - A string containing the host the API should communicate with. Defaults to `ENV['DOCKER_HOST']` if set.
- `tls` - Use TLS; implied by --tlsverify. Defaults to ENV['DOCKER_TLS'] if set.
- `tls_verify` - Use TLS and verify the remote. Defaults to `ENV['DOCKER_TLS_VERIFY']` if set
- `tls_ca_cert` - Trust certs signed only by this CA. Defaults to `ENV['DOCKER_CERT_PATH']` if set.
- `tls_client_cert` - Path to TLS certificate file for docker cli. Defaults to `ENV['DOCKER_CERT_PATH']` if set
- `tls_client_key` - Path to TLS key file for docker cli. Defaults to `ENV['DOCKER_CERT_PATH']` if set.
- `buildargs` - A String or Hash containing build arguments.

## Examples

- default action, default properties

```ruby
docker_image 'hello-world'
```

- non-default name property

```ruby
docker_image "Tom's container" do
  repo 'tduffield/testcontainerd'
  action :pull
end
```

- pull every time

```ruby
docker_image 'busybox' do
  action :pull
end
```

- specify a tag

```ruby
docker_image 'alpine' do
  tag '3.1'
end
```

- specify read/write timeouts

```ruby
docker_image 'alpine' do
  read_timeout 60
  write_timeout 60
end
```

```ruby
docker_image 'vbatts/slackware' do
  action :remove
end
```

- save

```ruby
docker_image 'save hello-world' do
  repo 'hello-world'
  destination '/tmp/hello-world.tar'
  not_if { ::File.exist?('/tmp/hello-world.tar') }
  action :save
end
```

- build from a Dockerfile on every chef-client run

```ruby
docker_image 'image_1' do
  tag 'v0.1.0'
  source '/src/myproject/container1/Dockerfile'
  action :build
end
```

- build from a directory, only if image is missing

```ruby
docker_image 'image_2' do
  tag 'v0.1.0'
  source '/src/myproject/container2'
  action :build_if_missing
end
```

- build from a tarball NOTE: this is not an "export" tarball generated from an image save. The contents should be a Dockerfile, and anything it references to COPY or ADD

```ruby
docker_image 'image_3' do
  tag 'v0.1.0'
  source '/tmp/image_3.tar'
  action :build
end
```

```ruby
docker_image 'hello-again' do
  tag 'v0.1.0'
  source '/tmp/hello-world.tar'
  action :import
end
```

- build from a Dockerfile on every chef-client run with `buildargs`

Acceptable values for `buildargs`:

String:

`buildargs '{"IMAGE_NAME":"alpine","IMAGE_TAG":"latest"}'`

Hash:

`buildargs "IMAGE_NAME": "alpine", "IMAGE_TAG": "latest"`

`buildargs "IMAGE_NAME" => "alpine", "IMAGE_TAG" => "latest"`

```ruby
docker_image 'image_1' do
  source '/src/myproject/container1/Dockerfile'
  buildargs '{"IMAGE_NAME":"alpine","IMAGE_TAG":"latest"}'
  action :build
end
```

Where `Dockerfile` contains:

``` bash
ARG IMAGE_TAG
ARG IMAGE_NAME
FROM $IMAGE_NAME:$IMAGE_TAG
ARG IMAGE_NAME
ENV image_name=$IMAGE_NAME
RUN echo $image_name > /image_name
```

- push

```ruby
docker_image 'my.computers.biz:5043/someara/hello-again' do
  action :push
end
```

- Connect to an external docker daemon and pull an image

```ruby
docker_image 'alpine' do
  host 'tcp://127.0.0.1:2376'
  tag '2.7'
end
```
