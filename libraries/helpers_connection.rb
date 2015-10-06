module DockerHelpers
  module Connection
    def parsed_connect_host
      new_resource.host || Docker.url
    end

    def parsed_connect_options
      opts = {}
      opts['read_timeout'] = new_resource.read_timeout unless new_resource.read_timeout.nil?
      opts['write_timeout'] = new_resource.write_timeout unless new_resource.write_timeout.nil?
      opts
    end
  end
end
