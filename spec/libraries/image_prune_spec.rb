require 'spec_helper'
# require_relative '../../libraries/docker_base'
# require_relative '../../libraries/docker_image_prune'

# describe DockerCookbook::DockerImagePrune do
#   let(:resource) { DockerCookbook::DockerImagePrune.new('rspec') }

#   it 'generates filter json' do
#     # Arrange
#     expected = '{"filters":["dangling=true","until=1h30m","label=com.example.vendor=ACME","label!=no_prune"]}'
#     resource.dangling = true
#     resource.prune_until = '1h30m'
#     resource.with_label = 'com.example.vendor=ACME'
#     resource.without_label = 'no_prune'
#     resource.action :prune

#     # Act
#     actual = resource.generate_json(resource)

#     # Assert
#     expect(actual).to eq(expected)
#   end
# end

describe 'docker_image_prune' do
  step_into :docker_image_prune
  platform 'ubuntu'
  context 'generates filter json'

  recipe do
    docker_image_prune do
      dangling true
      prune_until '1h30m'
      without_label 'com.example.vendor=ACME'
    end
  end

  it 'prunes the image' do
    is_expected.to 
  end
end
