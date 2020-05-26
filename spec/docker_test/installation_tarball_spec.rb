require 'spec_helper'

describe 'docker_test::installation_tarball' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu',
                             version: '18.04',
                             step_into: ['docker_installation_tarball']).converge(described_recipe)
  end

  # Coverage of all recent docker versions
  # To ensure test coverage and backwards compatibility
  # With the frequent changes in package naming convention
  # List generated from
  # https://download.docker.com/linux/static/stable/x86_64/

  context 'tarball file names for Ubuntu 18.04' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu',
                               version: '18.04',
                               step_into: ['docker_installation_package']).converge(described_recipe)
    end

    [
      { docker_version: '18.03.1', expected: 'docker-18.03.1-ce.tgz' },
      { docker_version: '18.06.3', expected: 'docker-18.06.3-ce.tgz' },
      { docker_version: '18.09.0', expected: 'docker-18.09.0.tgz' },
      { docker_version: '19.03.5', expected: 'docker-19.03.5.tgz' },
    ].each do |suite|
      it 'generates the correct file name for tarball' do
        custom_resource = chef_run.docker_installation_tarball('default')
        actual = custom_resource.default_filename(suite[:docker_version])
        expect(actual).to eq(suite[:expected])
      end
    end
  end
end
