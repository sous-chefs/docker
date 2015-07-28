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
  not_if { ::File.exist? '/tmp/busybox_marker' }
  notifies :run, 'execute[busybox marker]'
end

# This marker business is so chef-client does't :pull during
# subsequent test-kitchen converges.
execute 'busybox marker' do
  command 'touch /tmp/busybox_marker'
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
  command 'docker pull vbatts/slackware ; touch /tmp/slackware_marker'
  creates '/tmp/slackware_marker'
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
  destination '/tmp/hello-world.tar'
  not_if { ::File.exist? '/tmp/hello-world.tar' }
  action :save
end

########
# :build
########

# Build from a Dockerfile
directory '/tmp/container1' do
  action :create
end

cookbook_file '/tmp/container1/Dockerfile' do
  source 'Dockerfile_1'
  action :create
end

docker_image 'image_1' do
  tag 'v0.1.0'
  source '/tmp/container1/Dockerfile'
  not_if { ::File.exist? '/tmp/image_1_marker' }
  notifies :run, 'execute[image_1 marker]'
  action :build
end

execute 'image_1 marker' do
  command 'touch /tmp/image_1_marker'
  action :nothing
end

# Build from a directory
directory '/tmp/container2' do
  action :create
end

file '/tmp/container2/foo.txt' do
  content 'Dockerfile_2 contains ADD for this file'
  action :create
end

cookbook_file '/tmp/container2/Dockerfile' do
  source 'Dockerfile_2'
  action :create
end

docker_image 'image_2' do
  tag 'v0.1.0'
  source '/tmp/container2'
  action :build_if_missing
end

# Build from a tarball
cookbook_file '/tmp/image_3.tar' do
  source 'image_3.tar'
  action :create
end

docker_image 'image_3' do
  tag 'v0.1.0'
  source '/tmp/image_3.tar'
  action :build_if_missing
end

#########
# :import
#########

docker_image 'hello-again' do
  tag 'v0.1.0'
  source '/tmp/hello-world.tar'
  action :import
end

################
# :tag and :push
################

include_recipe 'docker_test::registry'

docker_tag 'private repo tag for hello-again:1.0.1' do
  target_repo 'hello-again'
  target_tag 'v0.1.0'
  to_repo 'localhost:5000/someara/hello-again'
  to_tag 'latest'
  action :tag
end
