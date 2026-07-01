# frozen_string_literal: true

class DockerContainer < Inspec.resource(1)
  name 'docker_container'
  desc 'Minimal Docker container checks for this cookbook profile'

  def initialize(container)
    @container = container
  end

  def exist?
    inspec.command("docker container inspect #{@container}").exit_status.zero?
  end

  def running?
    inspec.command("docker container inspect -f '{{ .State.Running }}' #{@container}").stdout.strip == 'true'
  end

  def ports
    inspec.command("docker ps -a --filter 'name=^/#{@container}$' --format '{{ .Ports }}'").stdout.strip
  end

  def to_s
    "Docker container #{@container}"
  end
end
