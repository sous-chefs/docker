module Helpers
  module DockerTest
    require 'chef/mixin/shell_out'
    include Chef::Mixin::ShellOut
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources

    def container_exists?(image,command)
      dps = shell_out("docker ps -a -notrunc")
      dps.stdout.include?(command)
    end

    def container_running?(image,command)
      dps = shell_out("docker ps -a -notrunc")
      dps.stdout.each_line do |dps_line|
        return true if dps_line.include?(command) && dps_line.include?("Up")
      end
      false
    end

    def image_exists?(image)
      di = shell_out("docker images -a")
      di.stdout.include?(image)
    end

  end
end
