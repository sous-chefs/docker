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
        # when FalseClass
        #   cli_line += " -#{arg}=false"
        when Fixnum, Integer, String
          cli_line += " -#{arg} #{value}"
        when TrueClass
          # cli_line += " -#{arg}=true"
          cli_line += " -#{arg}"
        end
      end
      cli_line
    end
  end
end
