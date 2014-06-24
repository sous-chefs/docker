module Serverspec
  module Type
    
    class DockerImage < Base
      require 'mixlib/shellout'
      require 'docker'

      attr_reader :name
      attr_reader :image

      def initialize(name)
        @name   = with_latest(name)
        @image  = find_image
        super
      end

      # it { should be_an_image }
      def image?
        !!@image
      end

      private

      def find_image
        images = Docker::Image.all(:all => true)
        images.each do |image|
          if image.info['RepoTags'].include?(@name)
            return image
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
