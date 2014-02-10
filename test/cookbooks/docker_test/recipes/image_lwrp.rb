docker_image "base" do
  tag "ubuntu-quantal"
end

docker_image "busybox"
docker_image 'bflad/testcontainerd'

docker_image "base" do
  tag "ubuntu-quantal"
  action :remove
end

fname = "/tmp/docker_image_build.dockerfile"

cookbook_file fname do
  source "Dockerfile"
end

docker_image "myImage" do
  tag "myTag"
  source fname
  action :build
end

docker_image "myImage" do
  tag "myTag"
  action :remove
end
