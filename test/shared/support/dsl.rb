module RSpec
  module Core
    #
    module DSL

      def docker_imag(name)
        Serverspec::Type::DockerImage.new(name)
      end

      def docker_container(image, command = nil)
        Serverspec::Type::DockerContainer.new(image, command)
      end

    end
  end
end
