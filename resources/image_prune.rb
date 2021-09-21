unified_mode true
use 'partial/_base'

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
  json = generate_json(new_resource)

  res = connection.post('/images/prune', json)
  Chef::Log.info res
end

action_class do
  include DockerCookbook::DockerHelpers::Json
end
