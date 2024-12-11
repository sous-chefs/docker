# TODO: Refactor test
require 'spec_helper'
require_relative '../../libraries/helpers_json'

RSpec.describe DockerCookbook::DockerHelpers::Json do
  class DummyClass < Chef::Node
    include DockerCookbook::DockerHelpers::Json
  end

  subject { DummyClass.new }

  describe '#generate_json' do
    it 'generates filter json' do
      dangling = true
      prune_until = '1h30m'
      with_label = 'com.example.vendor=ACME'
      without_label = 'no_prune'
      expected = 'filters=%7B%22dangling%22%3A%7B%22true%22%3Atrue%7D%2C%22until%22%3A%7B%221h30m%22%3Atrue%7D%2C%22label%22%3A%7B%22com.example.vendor%3DACME%22%3Atrue%7D%2C%22label%21%22%3A%7B%22no_prune%22%3Atrue%7D%7D'

      expect(subject.prune_generate_json(dangling: dangling, prune_until: prune_until, with_label: with_label, without_label: without_label)).to eq(expected)
    end
  end
end
