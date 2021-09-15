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
    end
  end
end
