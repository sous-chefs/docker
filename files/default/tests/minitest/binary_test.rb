require File.expand_path('../support/helpers', __FILE__)

describe_recipe 'docker::binary' do
  include Helpers::Docker

  it 'installs docker binary' do
    file("#{node['docker']['install_dir']}/docker").must_exist
  end
end
