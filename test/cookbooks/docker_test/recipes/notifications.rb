# service
include_recipe 'docker_test::default'

# container A
directory '/alice' do
  action :create
end

file '/alice/Dockerfile' do
  content <<-EOF
  FROM alpine
  MAINTAINER alice@computers.biz
  COPY file /
  EOF
  action :create
end

file '/alice/file' do
  content 'alice was here\n'
  action :create
end

docker_image 'alice/bits' do
  source '/alice'
  tag 'latest'
  force true
  subscribes :build, 'file[/alice/Dockerfile]'
  subscribes :build, 'file[/alice/file]'
  action :build_if_missing
end

docker_container 'alice' do
  repo 'alice/bits'
  command 'nc -ll -p 777 -e /bin/cat'
  action :run
  subscribes :redeploy, 'docker_image[alice/bits]'
end

# container B
directory '/bob' do
  action :create
end

file '/bob/Dockerfile' do
  content <<-EOF
  FROM alpine
  MAINTAINER bob@computers.biz
  COPY file /
  EOF
  action :create
end

file '/bob/file' do
  content 'bob was here\n'
  action :create
end

docker_image 'bob/bits' do
  source '/bob'
  tag 'latest'
  force true
  subscribes :build, 'file[/bob/Dockerfile]'
  subscribes :build, 'file[/bob/file]'
  action :build_if_missing
end

docker_container 'bob' do
  repo 'bob/bits'
  links 'alice:alice'
  command 'nc -ll -p 888 -e /bin/cat'
  action :run
  subscribes :redeploy, 'docker_image[bob/bits]'
  subscribes :redeploy, 'docker_container[alice]'
end
