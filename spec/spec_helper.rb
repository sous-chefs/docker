require 'chefspec'
require 'chefspec/berkshelf'

at_exit { ChefSpec::Coverage.report! }

class RSpecHelper
  class<<self
    attr_accessor :current_example
    attr_accessor :api_version
  end
  def self.reset!
    @current_example = nil
    @api_version = '1.18'
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
