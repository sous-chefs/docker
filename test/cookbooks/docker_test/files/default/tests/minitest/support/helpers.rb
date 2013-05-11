module Helpers
  module DockerTest
    require 'chef/mixin/shell_out'
    include Chef::Mixin::ShellOut
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    def image_exists?(image)
      di = shell_out("docker images -a")
      di.stdout.include?(image)
    end

  end
end
