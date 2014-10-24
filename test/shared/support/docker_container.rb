module Serverspec
  module Type

    # Serverspec::Type Container
    class DockerContainer < Base
      require 'mixlib/shellout'
      require 'docker'

      attr_reader :image
      attr_reader :command

      def initialize(image, command = nil)
        @image      = image
        @command    = command
        @container  = find_container
        if command
          super("#{@image} running #{@command}")
        else
          super("#{@image}")
        end
      end

      # it { should be_a_container }
      def container?
        return true if @container
        false
      end

      # it { should be_running }
      def running?
        return @container.info['Status'].match(/^Up/) if @container
        false
      end

      private

      def container_command_matches_if_exists?(container)
        return false if @command && container.info['Command'] != @command
        true
      end

      def container_image_matches?(container)
        return true if container.info['Image'] == @image || container.info['Image'].split(':').first == @image
        false
      end

      def container_matches?(container)
        if container_image_matches?(container)
          return false unless container_command_matches_if_exists?(container)
          return true
        end
        false
      end

      def find_container
        containers = Docker::Container.all(:all => true)
        containers.each do |container|
          return container if container_matches?(container)
        end
        nil
      end
    end
  end
end
