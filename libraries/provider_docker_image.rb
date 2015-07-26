$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'docker'

class Chef
  class Provider
    class DockerImage < Chef::Provider::LWRPBase
      # register with the resource resolution system
      if Chef::Provider.respond_to?(:provides)
        provides :docker_image
      end

      # Mix in helpers from libraries/helpers.rb
      include DockerHelpers

      action :build do
        # FIXME: add some error handling so we get a friendlier error
        # message if dockerfile isn't found or whatever
        dockerfile = IO.read(new_resource.source)
        i = Docker::Image.build(dockerfile)
        new_resource.updated_by_last_action(true)
        i.tag('repo' => new_resource.image_name, 'tag' => new_resource.tag, 'force' => true)
        new_resource.updated_by_last_action(true)
      end

      action :build_if_missing do
        # FIXME: reduce code cuplication between if_missing
        @repotags = []
        Docker::Image.all.each { |i| @repotags << i.info['RepoTags'] }
        next if @repotags.include?(["#{new_resource.image_name}:#{new_resource.tag}"])

        dockerfile = IO.read(new_resource.source)
        i = Docker::Image.build(dockerfile)
        new_resource.updated_by_last_action(true)
        i.tag('repo' => new_resource.image_name, 'tag' => new_resource.tag, 'force' => true)
        new_resource.updated_by_last_action(true)
      end

      action :import do
      end

      action :load do
      end

      # Explicitly pull every time.
      # Good for grabing latest tag.
      action :pull do
        # FIXME: add some error handling so we get a friendlier error
        # message if an image isn't found or whatever.
        Docker::Image.create(
          'fromImage' => new_resource.image_name,
          'tag' => new_resource.tag
          )
        new_resource.updated_by_last_action(true)
      end

      # The convergent version of :pull
      action :pull_if_missing do
        # test
        @repotags = []
        Docker::Image.all.each { |i| @repotags << i.info['RepoTags'] }
        next if @repotags.include?(["#{new_resource.image_name}:#{new_resource.tag}"])

        # repair
        Docker::Image.create(
          'fromImage' => new_resource.image_name,
          'tag' => new_resource.tag
          )
        new_resource.updated_by_last_action(true)
      end

      action :push do
      end

      action :remove do
        begin
          i = Docker::Image.get(new_resource.image_name)
          i.remove
        rescue Docker::Error::NotFoundError
          next
        end
        new_resource.updated_by_last_action(true)
      end

      # Export to tarball
      action :save do
      end

      action :tag do
      end

    end
  end
end
