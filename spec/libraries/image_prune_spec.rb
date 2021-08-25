require 'spec_helper'
require_relative '../../libraries/docker_base'
require_relative '../../libraries/docker_image_prune'

describe DockerCookbook::DockerImagePrune do
  let(:resource) { DockerCookbook::DockerImagePrune.new('rspec') }

  it 'has a default action of [:prune]' do
    expect(resource.action).to eql([:prune])
  end

  it 'generates filter json' do
    # Arrange
    expected = 'filters=%7B%22dangling%22%3A%7B%22true%22%3Atrue%7D%2C%22until%22%3A%7B%221h30m%22%3Atrue%7D%2C%22label%22%3A%7B%22com.example.vendor%3DACME%22%3Atrue%7D%2C%22label%21%22%3A%7B%22no_prune%22%3Atrue%7D%7D'
    resource.dangling = true
    resource.prune_until = '1h30m'
    resource.with_label = 'com.example.vendor=ACME'
    resource.without_label = 'no_prune'
    resource.action :prune

    # Act
    actual = resource.generate_json(resource)

    # Assert
    expect(actual).to eq(expected)
  end
end
