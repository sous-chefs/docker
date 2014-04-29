module RSpec
  module Core
    #
    module DSL

      def docker_container(name, command = nil)
        Serverspec::Type::DockerContainer.new(name, command)
      end

      def docker_image(name=nil)
        Serverspec::Type::DockerImage.new(name)
      end
    end
  end
end
