#########################
# :pull_if_missing, :pull
#########################

# default action, default properties
docker_image 'hello-world'

# non-default name attribute, containing a single quote
docker_image "Tom's container" do
  image_name 'tduffield/testcontainerd'
end

# :pull action specified
docker_image 'busybox' do
  action :pull
  not_if { ::File.exist? '/tmp/busybox_marker' }
  notifies :run, 'execute[busybox marker]'
end

# This marker business is so  chef-client does't :pull  during
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
execute 'pull nginx' do
  command 'docker pull nginx ; touch /tmp/nginx_marker'
  creates '/tmp/nginx_marker'
  action :run
end

docker_image 'nginx' do
  action :remove
end

########
# :build
########

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

# docker_image_build_2_dir = '/tmp/docker_image_build_2'

# directory docker_image_build_2_dir

# file "#{docker_image_build_2_dir}/foo.txt" do
#   content 'Dockerfile_2 contains ADD for this file'
# end

# cookbook_file "#{docker_image_build_2_dir}/Dockerfile" do
#   source 'Dockerfile_2'
# end

# docker_image 'docker_image_build_2' do
#   source docker_image_build_2_dir
#   action :build
# end
