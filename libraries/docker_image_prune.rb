module DockerCookbook
  class DockerImagePrune < DockerBase
    resource_name :docker_image_prune
    provides :docker_image_prune
    # Requires docker API v1.25
    # Modify the default of read_timeout from 60 to 120
    property :read_timeout, Integer, default: 120, desired_state: false
    property :host, [String, nil], default: lazy { ENV['DOCKER_HOST'] }, desired_state: false

    # https://docs.docker.com/engine/api/v1.35/#operation/ImagePrune
    property :dangling, [true, false], default: true
    property :prune_until, String
    # https://docs.docker.com/engine/reference/builder/#label
    property :with_label, String
    property :without_label, String

    #########
    # Actions
    #########

    default_action :prune

    action :prune do
      # Have to call this method ourselves due to
      # https://github.com/swipely/docker-api/pull/507
      json = generate_json(new_resource)
      # Post
      res = connection.post('/images/prune', json)
      Chef::Log.info res
    end

    def generate_json(new_resource)
      opts = { dangling: { "#{new_resource.dangling}": true } }
      opts['until'] = { "#{new_resource.prune_until}": true } if new_resource.property_is_set?(:prune_until)
      opts['label'] = { "#{new_resource.with_label}": true } if new_resource.property_is_set?(:with_label)
      opts['label!'] = { "#{new_resource.without_label}": true } if new_resource.property_is_set?(:without_label)
      'filters=' + URI.encode_www_form_component(opts.to_json)
    end
  end
end
