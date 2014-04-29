module Serverspec
  module Type

    # Serverspec::Type Container
    class DockerContainer < Base
      require 'mixlib/shellout'

      attr_reader :name
      attr_reader :command

      def initialize(name, command = nil)
        @name     = name
        @command  = command
      end
      
      # it { should be_a_container }
      def container?
        cmd = Mixlib::ShellOut.new("docker ps -a -notrunc", timeout: 30)
        dps = cmd.run_command
        return dps.stdout.include?(@command) if @command
        dps.stdout.include?(@name)
      end

      # it { should be_running }
      def running?
        cmd = Mixlib::ShellOut.new("docker ps -a -notrunc", timeout: 30)
        dps = cmd.run_command
        dps.stdout.each_line do |dps_line|
          if @command
            return dps_line.include?("Up") if dps_line.include?(@command)
          else
            return dps_line.include?("Up") if dps_line.include?(@name)
          end
        end
        false
      end
    end
  end
end
