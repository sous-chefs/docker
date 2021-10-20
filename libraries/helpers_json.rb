module DockerCookbook
  module DockerHelpers
    module Json
      def generate_json(dangling, prune_until, with_label, without_label)
        opts = { dangling: { "#{dangling}": true } }
        opts['until'] = { "#{prune_until}": true } unless prune_until == nil?
        opts['label'] = { "#{with_label}": true } unless with_label == nil?
        opts['label!'] = { "#{without_label}": true } unless without_label == nil?
        'filters=' + URI.encode_www_form_component(opts.to_json)
      end
    end
  end
end
