module DockerCookbook
  class DockerNetwork < DockerBase
    require 'docker'
    require 'helpers_network'

    use_automatic_resource_name

    property :network_name, String, name_property: true
    property :host, [String, nil], default: lazy { default_host }
    property :id, String
    property :driver, [String, nil]
    property :driver_opts, [String, Array, nil]

    property :ipam_driver, String
    property :aux_address, [String, Array, nil]
    property :gateway, [String, Array, nil]
    property :ip_range, [String, Array, nil]
    property :subnet, [String, Array, nil]

    property :network, Docker::Network, desired_state: false
    property :container, [String, Array, nil]

    load_current_value do
      begin
        with_retries { network Docker::Network.get(network_name, {}, connection) }
      rescue Docker::Error::NotFoundError
        current_value_does_not_exist!
      end
    end

    declare_action_class.class_eval do
      include DockerHelpers::Network
    end

    action :create do
      return if current_resource
      converge_by "creating #{network_name}" do
        with_retries do
          options = {}
          options['Driver'] = driver if driver
          options['Options'] = driver_opts if driver_opts
          ipam_options = consolidate_ipam(subnet, ip_range, gateway, aux_address)
          options['IPAM'] = { 'Config' => ipam_options } if ipam_options.size > 0
          options['IPAM']['Driver'] = ipam_driver if ipam_driver
          Docker::Network.create(network_name, options)
        end
      end
    end

    action :delete do
      return unless current_resource
      converge_by "deleting #{network_name}" do
        with_retries do
          network.delete
        end
      end
    end

    action :remove do
      action_delete
    end

    action :connect do
      return unless current_resource
      return unless container
      converge_if_changed do
        with_retries do
          network.connect(container)
        end
      end
    end

    action :disconnect do
      return unless current_resource
      return unless container
      converge_if_changed do
        with_retries do
          network.disconnect(container)
        end
      end
    end
  end
end
