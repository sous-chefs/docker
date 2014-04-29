module Serverspec
  module Type
    
    class DockerImage < Base
      require 'mixlib/shellout'

      attr_reader :name

      def initialize(name)
        @name = name
        super
      end

      # it { should be_an_image }
      def image?
        cmd = Mixlib::ShellOut.new('docker images -a', timeout: 30)
        di = cmd.run_command
        di.stdout.include?(@name)
      end
    end
  end
end
