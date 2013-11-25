require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker::configuration' do
  include Helpers::Docker

  it 'has docker configuration file' do
    assert_file "#{node['docker']['config_dir']}/docker", 'root', 'root', '644'
  end
end
