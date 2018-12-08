module DockerCookbook
  class DockerImagePrune < DockerBase
    resource_name :docker_image_prune

    # Modify the default of read_timeout from 60 to 120
    property :read_timeout, default: 120, desired_state: false

    # https://docs.docker.com/engine/api/v1.35/#operation/ImagePrune
    property :dangling, [TrueClass, FalseClass], default: false
    property :prune_until, String
    # https://docs.docker.com/engine/reference/builder/#label
    property :label, Array, default: []

    #########
    # Actions
    #########

    default_action :prune

    action :prune do
      # Have to call this method ourselves due to
      # https://github.com/swipely/docker-api/pull/507
      # {filters: {dangling: ['false']}.to_json}
      #
      opts = {filters: {
        dangling: new_resource.dangling
      }}
      opts.filters.merge(until: new_resource.prune_until) if new_resource.property_is_set?(:prune_until)
      opts.filters.merge(label: new_resource.label) if new_resource.property_is_set?(:label)

      # Post
      res = conn.post("/images/prune", opts.to_json)
      Chef::Log.info res
    end
  end
end
