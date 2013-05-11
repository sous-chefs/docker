site :opscode

metadata

# See: https://github.com/NOX73/chef-golang/pull/4
# cookbook "golang", github: "NOX73/chef-golang"
cookbook "golang", github: "buth/chef-golang", ref: "lwrps"
cookbook "lxc", github: "hw-cookbooks/lxc"
cookbook "modules", github: "Youscribe/modules-cookbook"

group :integration do
  cookbook "minitest-handler"
  cookbook "docker_test", path: "test/cookbooks/docker_test"
end
