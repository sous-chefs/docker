# frozen_string_literal: true

class DockerImage < Inspec.resource(1)
  name 'docker_image'
  desc 'Minimal Docker image checks for this cookbook profile'

  def initialize(image)
    @image = image
  end

  def exist?
    inspec.command("docker image inspect #{@image}").exit_status.zero?
  end

  def repo
    return unless exist?

    @image.sub(%r{:[^/:]+$}, '')
  end

  def tag
    return unless exist?

    @image[%r{(?<=:)[^/:]+$}] || 'latest'
  end

  def to_s
    "Docker image #{@image}"
  end
end
