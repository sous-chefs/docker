# Helpers module
module Helpers
  # Helpers::Docker module
  module Docker
    def cli_args(spec)
      cli_line = ''
      spec.each_pair do |arg, value|
        case value
        when Array
          cli_line += value.map { |a| " -#{arg} " + a }.join
        when FalseClass
          cli_line += " -#{arg}=false"
        when Fixnum, Integer, String
          cli_line += " -#{arg} #{value}"
        when TrueClass
          cli_line += " -#{arg}=true"
        end
      end
      cli_line
    end

    def docker_inspect(id)
      require 'json'
      JSON.parse(docker_cmd("inspect #{id}").stdout)[0]
    end

    def docker_inspect_id(id)
      inspect = docker_inspect(id)
      inspect['id'] if inspect
    end
  end
end
