docker_image "base"
docker_image "busybox"

docker_image "base" do
  action :remove
end

fname = "/tmp/docker_image_build.dockerfile"

cookbook_file fname do
  source "Dockerfile"
end

docker_image "myImage" do
  tag "myTag"
  dockerfile fname
  action :build
end

docker_image "myImage" do
  action :remove
end
