# frozen_string_literal: true

unified_mode true
use '_partial/_base'

resource_name :docker_image_prune
provides :docker_image_prune

property :read_timeout, Integer, default: 120, desired_state: false
property :host, [String, nil], default: lazy { ENV['DOCKER_HOST'] }, desired_state: false

# https://docs.docker.com/engine/api/v1.35/#operation/ImagePrune
property :dangling, [true, false], default: true
property :prune_until, String
# https://docs.docker.com/engine/reference/builder/#label
property :with_label, String
property :without_label, String

action :prune do
  # Have to call this method ourselves due to
  # https://github.com/swipely/docker-api/pull/507
  json = prune_generate_json(dangling: new_resource.dangling, prune_until: new_resource.prune_until, with_label: new_resource.with_label, without_label: new_resource.without_label)

  res = connection.post('/images/prune', json)
  Chef::Log.info res
end

action_class do
  include DockerCookbook::DockerHelpers::Json
end
