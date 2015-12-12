require 'docker'

# Set the Docker api version
RSpecHelper.current_example.instance_eval do
  allow(Docker).to receive(:version).and_return('ApiVersion' => RSpecHelper.api_version)
end
