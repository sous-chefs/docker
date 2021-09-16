module DockerCookbook
  module DockerHelpers
    module Build
      def coerce_buildargs(v)
        "{ #{v.map { |key, value| "\"#{key}\": \"#{value}\"" }.join(', ')} }"
      end
    end
  end
end
