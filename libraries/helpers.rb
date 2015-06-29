# Docker module
module Docker
  # Docker::Helpers module
  module Helpers
    # Exception to signify that the Docker daemon is not yet ready to handle
    # docker commands.
    class DockerNotReady < StandardError
      def initialize(timeout)
        super <<-EOH
The Docker daemon did not become ready within #{timeout} seconds.
This most likely means that Docker failed to start.
Docker can fail to start if:

  - a configuration file is invalid
  - permissions are incorrect for the root directory of the docker runtime.

If this problem persists, check your service log files.
EOH
      end
    end

    # Exception to signify that the docker command timed out.
    class CommandTimeout < RuntimeError; end

    # Daemon service name
    def self.docker_service(node)
      return 'docker.io' if Docker::Helpers.using_docker_io_package?(node)
      'docker'
    end

    # Path to settings file
    def self.docker_settings_file(node)
      case node['platform']
      when 'debian'
        '/etc/default/docker'
      when 'ubuntu'
        if Docker::Helpers.using_docker_io_package?(node)
          '/etc/default/docker.io'
        else
          '/etc/default/docker'
        end
      else
        '/etc/sysconfig/docker'
      end
    end

    # Path to Upstart configuration file
    def self.docker_upstart_conf_file(node)
      case node['platform']
      when 'ubuntu'
        if Docker::Helpers.using_docker_io_package?(node)
          '/etc/init/docker.io.conf'
        else
          '/etc/init/docker.conf'
        end
      else
        '/etc/init/docker.conf'
      end
    end

    # Path to docker executable
    def self.executable(node)
      return '/usr/bin/docker.io' if Docker::Helpers.using_docker_io_package?(node)
      "#{node['docker']['install_dir']}/docker"
    end

    # Boolean to determine whether or not we are using the docker.io package
    def self.using_docker_io_package?(node)
      node['docker']['install_type'] == 'package' &&
        node['docker']['package']['name'] == 'docker.io'
    end

    def self.daemon_cli_args(node)
      daemon_options = Docker::Helpers.cli_args(
        'api-enable-cors' => node['docker']['api_enable_cors'],
        'bip' => node['docker']['bip'],
        'bridge' => node['docker']['bridge'],
        'debug' => node['docker']['debug'],
        'dns' => Array(node['docker']['dns']),
        'dns-search' => Array(node['docker']['dns_search']),
        'exec-driver' => node['docker']['exec_driver'],
        'host' => Array(node['docker']['host']),
        'graph' => node['docker']['graph'],
        'group' => node['docker']['group'],
        'icc' => node['docker']['icc'],
        'insecure-registry' => Array(node['docker']['insecure-registry']),
        'ip' => node['docker']['ip'],
        'iptables' => node['docker']['iptables'],
        'mtu' => node['docker']['mtu'],
        'pidfile' => node['docker']['pidfile'],
        'registry-mirror' => Array(node['docker']['registry-mirror']),
        'restart' => node['docker']['restart'],
        'selinux-enabled' => node['docker']['selinux_enabled'],
        'storage-driver' => node['docker']['storage_driver'],
        'storage-opt' => Array(node['docker']['storage_opt']),
        'tls' => node['docker']['tls'],
        'tlscacert' => node['docker']['tlscacert'],
        'tlscert' => node['docker']['tlscert'],
        'tlskey' => node['docker']['tlskey'],
        'tlsverify' => node['docker']['tlsverify']
      )
      daemon_options += " #{node['docker']['options']}" if node['docker']['options']
      daemon_options
    end

    # NOTE: This method has custom daemon arg handling for
    # the daemon options since they do not parse quotes correctly
    # e.g. --exec-driver="lxc"
    # e.g. --host="unix:///var/run/docker.sock"
    # e.g. --storage-driver="aufs"
    # This probably should be opened as a bug in Docker
    def self.cli_args(spec)
      cli_line = ''
      spec.each_pair do |arg, value|
        case value
        when Array
          next if value.empty?
          args = value.map do |v|
            " --#{arg}=#{v}"
          end
          cli_line += args.join
        when FalseClass, Fixnum, Integer, String, TrueClass
          cli_line += " --#{arg}=#{value}"
        end
      end
      cli_line
    end

    def cli_args(spec)
      cli_line = ''
      spec.each_pair do |arg, value|
        case value
        when Array
          next if value.empty?
          args = value.map do |v|
            v = "\"#{v}\"" if v.is_a?(String)
            " --#{arg}=#{v}"
          end
          cli_line += args.join
        when FalseClass, Fixnum, Integer, String, TrueClass
          value = "\"#{value}\"" if value.is_a?(String)
          cli_line += " --#{arg}=#{value}"
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
      # in docker < 1.0.0 the field is called 'id', but docker >= 1.0.0 it's called 'Id'.
      (inspect['id'] || inspect['Id']) if inspect
    end

    def dockercfg_parse
      require 'json'
      dockercfg = JSON.parse(::File.read(::File.join(::Dir.home, '.dockercfg')))
      dockercfg.each_pair do |k, v|
        dockercfg[k].merge!(dockercfg_parse_auth(v['auth']))
      end
      dockercfg
    rescue
      nil
    end

    def dockercfg_parse_auth(str)
      require 'base64'
      decoded_str = Base64.decode64(str)
      if decoded_str
        auth = {}
        auth['username'], auth['password'] = decoded_str.split(':')
        return auth
      end
      nil
    end

    def timeout
      node['docker']['docker_daemon_timeout']
    end

    # This is based upon wait_until_ready! from the opscode jenkins cookbook.
    #
    # Since the docker service returns immediately and the actual docker
    # process is started as a daemon, we block the Chef Client run until the
    # daemon is actually ready.
    #
    # This method will effectively "block" the current thread until the docker
    # daemon is ready
    #
    # @raise [DockerNotReady]
    #   if the Docker master does not respond within (+timeout+) seconds
    #
    def wait_until_ready!
      Timeout.timeout(timeout) do
        loop do
          result = shell_out('docker info')
          break if Array(result.valid_exit_codes).include?(result.exitstatus)
          Chef::Log.debug("Docker daemon is not running - #{result.stdout}\n#{result.stderr}")
          sleep(0.5)
        end
      end
    rescue Timeout::Error
      raise DockerNotReady.new(timeout), 'docker timeout exceeded'
    end

    # the Error message to display if a command times out. Subclasses
    # may want to override this to provide more details on the timeout.
    def command_timeout_error_message(cmd)
      <<-EOM

Command timed out:
#{cmd}

EOM
    end

    # Runs a docker command. Does not raise exception on non-zero exit code.
    def docker_cmd(cmd, timeout = new_resource.cmd_timeout)
      execute_cmd('docker ' + cmd, timeout)
    end

    # Executes the given command with the specified timeout. Does not raise an
    # exception on a non-zero exit code.
    def execute_cmd(cmd, timeout = new_resource.cmd_timeout)
      Chef::Log.debug('Executing: ' + cmd)
      begin
        shell_out(cmd, timeout: timeout)
      rescue Mixlib::ShellOut::CommandTimeout
        raise CommandTimeout, command_timeout_error_message(cmd)
      end
    end

    # Executes the given docker command with the specified timeout. Raises an
    # exception if the command returns a non-zero exit code.
    def docker_cmd!(cmd, timeout = new_resource.cmd_timeout)
      execute_cmd!('docker ' + cmd, timeout)
    end

    # Executes the given command with the specified timeout. Raises an
    # exception if the command returns a non-zero exit code.
    def execute_cmd!(cmd, timeout = new_resource.cmd_timeout)
      cmd = execute_cmd(cmd, timeout)
      cmd.error!
      cmd
    end

    def binary_installed?(bin)
      !shell_out("which #{bin}").error?
    end

    #
    # Pairs with the dep_check recipe.
    #
    # Parameters:
    # @execption - DockerCookbook exception to throw
    # @action - symbol representing which action to take
    # @msg - string of message to print
    #
    def alert_on_error(exception, action, msg)
      case action
      when :warn
        Chef::Log.warn <<-MSG
WARNING: #{exception}
#{msg}
        MSG
      when :fatal
        fail exception, msg
      end
    end
  end
end

# class Chef
class Chef
  # class Chef::Node
  class Node
    # recipe? is already taken
    # rubocop:disable PredicateName
    def has_recipe?(recipe_name)
      loaded_recipes.include?(with_default(recipe_name))
    end
    # rubocop:enable PredicateName

    private

    #
    # Automatically appends "+::default+" to recipes that need them.
    #
    # @param [String] name
    #
    # @return [String]
    #
    def with_default(name)
      name.include?('::') ? name : "#{name}::default"
    end

    #
    # The list of loaded recipes on the Chef run (normalized)
    #
    # @return [Array<String>]
    #
    def loaded_recipes
      node.run_context.loaded_recipes.map { |name| with_default(name) }
    end
  end
end

class DockerCookbook
  class Exceptions
    class MissingDependency < RuntimeError; end
    class InvalidPlatformVersion < StandardError; end
    class InvalidArchitecture < StandardError; end
    class InvalidKernelVersion < StandardError; end
  end
end
