site :opscode

metadata

cookbook "golang", github: "NOX73/chef-golang"
cookbook "lxc", github: "hw-cookbooks/lxc"
cookbook "modules", github: "Youscribe/modules-cookbook"

group :integration do
  cookbook "minitest-handler"
  cookbook "docker_test", path: "test/cookbooks/docker_test"
end
