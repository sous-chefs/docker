module DockerCookbook
  module DockerHelpers
    module Json
      def prune_generate_json(dangling:, prune_until: nil, with_label: nil, without_label: nil, all: false)
        opts = { dangling: { "#{dangling}": true } }
        opts['until'] = { "#{prune_until}": true } if prune_until
        opts['label'] = { "#{with_label}": true } if with_label
        opts['label!'] = { "#{without_label}": true } if without_label
        opts['all'] = true if all

        'filters=' + URI.encode_www_form_component(opts.to_json)
      end
    end
  end
end
