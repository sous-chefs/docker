module DockerCookbook
  module DockerHelpers
    module Container
      def cgroupv2?
        return if node.dig('filesystem', 'by_device').nil?
        node.dig('filesystem', 'by_device').key?('cgroup2')
      end
    end
  end
end
