require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker::default' do
  include Helpers::Docker
end
