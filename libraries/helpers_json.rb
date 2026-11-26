# frozen_string_literal: true

module DockerCookbook
  module DockerHelpers
    module Json
      def prune_generate_json(dangling: nil, prune_until: nil, with_label: nil, without_label: nil, all: false)
        opts = {}
        opts['dangling'] = { "#{dangling}": true } unless dangling.nil?
        opts['until'] = { "#{prune_until}": true } if prune_until
        opts['label'] = { "#{with_label}": true } if with_label
        opts['label!'] = { "#{without_label}": true } if without_label

        query = []
        query << 'filters=' + URI.encode_www_form_component(opts.to_json) unless opts.empty?
        query << 'all=true' if all
        query.join('&')
      end
    end
  end
end
