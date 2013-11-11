# Helpers module for minitest
module Helpers
  # Helpers::Docker module for minitest
  module Docker
    include MiniTest::Chef::Assertions
    include MiniTest::Chef::Context
    include MiniTest::Chef::Resources
  end
end
