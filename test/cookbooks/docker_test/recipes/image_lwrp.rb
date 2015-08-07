#########################
# :pull_if_missing, :pull
#########################

# default action, default properties
docker_image 'hello-world'

# non-default name attribute, containing a single quote
docker_image "Tom's container" do
  repo 'tduffield/testcontainerd'
end

# :pull action specified
docker_image 'busybox' do
  action :pull
  not_if { ::File.exist? '/image_marker_busybox' }
  notifies :run, 'execute[image_marker_busybox]'
end

# marker to prevent :run on subsequent converges.
execute 'image_marker_busybox' do
  command 'touch /image_marker_busybox'
  action :nothing
end

# specify a tag
docker_image 'alpine' do
  tag '3.1'
end

#########
# :remove
#########

# install something so it can be used to test the :remove action
execute 'pull vbatts/slackware' do
  command 'docker pull vbatts/slackware ; touch /image_marker_slackware'
  creates '/image_marker_slackware'
  action :run
end

docker_image 'vbatts/slackware' do
  action :remove
end

# ########
# # :save
# ########

docker_image 'save hello-world' do
  repo 'hello-world'
  destination '/hello-world.tar'
  not_if { ::File.exist? '/hello-world.tar' }
  action :save
end

########
# :build
########

# Build from a Dockerfile
directory '/usr/local/src/container1' do
  action :create
end

cookbook_file '/usr/local/src/container1/Dockerfile' do
  source 'Dockerfile_1'
  action :create
end

docker_image 'image_1' do
  tag 'v0.1.0'
  source '/usr/local/src/container1/Dockerfile'
  not_if { ::File.exist? '/image_marker_image_1' }
  notifies :run, 'execute[image_marker_image_1]'
  action :build
end

execute 'image_marker_image_1' do
  command 'touch /image_marker_image_1'
  action :nothing
end

# Build from a directory
directory '/usr/local/src/container2' do
  action :create
end

file '/usr/local/src/container2/foo.txt' do
  content 'Dockerfile_2 contains ADD for this file'
  action :create
end

cookbook_file '/usr/local/src/container2/Dockerfile' do
  source 'Dockerfile_2'
  action :create
end

docker_image 'image_2' do
  tag 'v0.1.0'
  source '/usr/local/src/container2'
  action :build_if_missing
end

# Build from a tarball
cookbook_file '/usr/local/src/image_3.tar' do
  source 'image_3.tar'
  action :create
end

docker_image 'image_3' do
  tag 'v0.1.0'
  source '/usr/local/src/image_3.tar'
  action :build_if_missing
end

#########
# :import
#########

docker_image 'hello-again' do
  tag 'v0.1.0'
  source '/hello-world.tar'
  action :import
end

################
# :tag and :push
################

docker_tag 'private repo tag for hello-again:1.0.1' do
  target_repo 'hello-again'
  target_tag 'v0.1.0'
  to_repo 'localhost:5043/someara/hello-again'
  to_tag 'latest'
  action :tag
end

docker_tag 'private repo tag for busybox:latest' do
  target_repo 'busybox'
  target_tag 'latest'
  to_repo 'localhost:5043/someara/busybox'
  to_tag 'latest'
  action :tag
end

include_recipe 'docker_test::registry'

docker_registry 'localhost:5043' do
  username 'testuser'
  password 'testpassword'
  email 'alice@computers.biz'
  action :login
end

docker_image 'localhost:5043/someara/busybox' do
  not_if { ::File.exist? '/image_marker_private_busybox' }
  notifies :run, 'execute[image_marker_private_busybox]'
  action :push
end

execute 'image_marker_private_busybox' do
  command 'touch /image_marker_private_busybox'
  action :nothing
end

docker_image 'localhost:5043/someara/hello-again' do
  not_if { ::File.exist? '/image_marker_private_hello-again' }
  notifies :run, 'execute[image_marker_private_hello-again]'
  action :push
end

execute 'image_marker_private_hello-again' do
  command 'touch /image_marker_private_hello-again'
  action :nothing
end
