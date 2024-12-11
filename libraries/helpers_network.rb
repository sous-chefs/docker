module DockerCookbook
  module DockerHelpers
    module Network
      # Gets the ip address from the existing container
      # current docker api of 1.16 does not have ['NetworkSettings']['Networks']
      # For docker > 1.21 - use ['NetworkSettings']['Networks']
      #
      #   @param container [Docker::Container] A container object
      #   @returns [String] An ip_address
      def ip_address_from_container_networks(container)
        # We use the first value in 'Networks'
        # We can't assume it will be 'bridged'
        # It might also not match the new_resource value
        if container.info['NetworkSettings'] &&
           container.info['NetworkSettings']['Networks'] &&
           container.info['NetworkSettings']['Networks'].values[0] &&
           container.info['NetworkSettings']['Networks'].values[0]['IPAMConfig'] &&
           container.info['NetworkSettings']['Networks'].values[0]['IPAMConfig']['IPv4Address']
          # Return the ip address listed
          container.info['NetworkSettings']['Networks'].values[0]['IPAMConfig']['IPv4Address']
        end
      end

      def normalize_container_network_mode(mode)
        return mode unless mode.is_a?(String) && mode.start_with?('container:')

        # Extract container name/id from network mode
        container_ref = mode.split(':', 2)[1]
        begin
          # Try to get the container by name or ID
          container = Docker::Container.get(container_ref, {}, connection)
          # Return normalized form with full container ID
          "container:#{container.id}"
        rescue Docker::Error::NotFoundError, Docker::Error::TimeoutError
          # If container not found, return original value
          mode
        end
      end
    end
  end
end
