# Load up docker and set the api version
$LOAD_PATH.unshift *Dir[File.expand_path('../../../docker/files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'
$LOAD_PATH.shift

# Set the Docker api version
RSpecHelper.current_example.instance_eval do
  allow(Docker).to receive(:version).and_return('ApiVersion' => RSpecHelper.api_version)
end
