docker_image 'docker-test-image'

docker_image 'busybox'
docker_image 'bflad/testcontainerd'

docker_image 'docker-test-image' do
  action :remove
end

docker_image_build_1_file = '/tmp/docker_image_build.dockerfile'

cookbook_file docker_image_build_1_file do
  source 'Dockerfile_1'
end

docker_image 'docker_image_build_1' do
  tag 'docker_image_build_1_tag'
  source docker_image_build_1_file
  action [:build, :remove]
end

docker_image_build_2_dir = '/tmp/docker_image_build_2'

directory docker_image_build_2_dir

file "#{docker_image_build_2_dir}/foo.txt" do
  content 'Dockerfile_2 contains ADD for this file'
end

cookbook_file "#{docker_image_build_2_dir}/Dockerfile" do
  source 'Dockerfile_2'
end

docker_image 'docker_image_build_2' do
  source docker_image_build_2_dir
  action :build
end
