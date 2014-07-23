module Serverspec
  module Type

    # Serverspec::Type Container
    class DockerContainer < Base
      require 'mixlib/shellout'
      require 'docker'

      attr_reader :image
      attr_reader :command

      def initialize(image, command = nil)
        @image      = with_latest(image)
        @command    = command
        @container  = find_container
        if !!command
          super("#{@image} running #{@command}")
        else
          super("#{@image}")
        end
      end
      
      # it { should be_a_container }
      def container?
        !!@container
      end

      # it { should be_running }
      def running?
        if @container
          !!@container.info['Status'].match(/^Up/)
        else
          false
        end
      end

      private

      def find_container
        containers = Docker::Container.all(:all => true)
        containers.each do |container|
          if @command == nil
            if container.info['Image'] == @image || container.info['Image'].split(':').first == @image
              return container
            end
          else
            if container.info['Command'] == @command 
              if container.info['Image'] == @image || container.info['Image'].split(':').first == @image
                return container
              end
            end
          end
        end
        return nil
      end

      def with_latest(image)
        image.include?(':') ? image : "#{image}:latest"
      end
    end
  end
end
