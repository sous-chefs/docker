require 'spec_helper'

describe 'docker_test::installation_package' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu',
                             version: '18.04',
                             step_into: ['docker_installation_package']).converge(described_recipe)
  end

  context 'testing default action, default properties' do
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default').with(version: '18.03.1')
    end
  end
end
