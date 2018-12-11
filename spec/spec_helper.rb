require 'chefspec'
require 'chefspec/berkshelf'
Dir['libraries/*.rb'].each do |f|
  if f.match?('docker_base|docker_image_prune|docker_container')
    require File.expand_path(f) unless f.match?('spec')
    end
end

class RSpecHelper
  class<<self
    attr_accessor :current_example
  end
  def self.reset!
    @current_example = nil
  end
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before :each do
    RSpecHelper.reset!
    RSpecHelper.current_example = self
  end
end
