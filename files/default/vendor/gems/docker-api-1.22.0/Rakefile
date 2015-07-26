$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rake'
require 'docker'
require 'rspec/core/rake_task'
require 'cane/rake_task'

task :default => [:spec, :quality]

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

Cane::RakeTask.new(:quality) do |cane|
  cane.canefile = '.cane'
end

dir = File.expand_path(File.dirname(__FILE__))
namespace :vcr do
  desc 'Run the full test suite from scratch'
  task :spec => [:unpack, :record]

  desc 'Download the necessary base images'
  task :unpack do
    %w( registry busybox tianon/true scratch debian:wheezy ).each do |image|
      system "docker pull #{image}"
    end
  end

  desc 'Run spec tests and record VCR cassettes'
  task :record do
    begin
      FileUtils.remove_dir("#{dir}/spec/vcr", true)
      registry = Docker::Container.create(
        'name' => 'registry',
        'Image' => 'registry',
        'Env' => ["GUNICORN_OPTS=[--preload]"],
        'ExposedPorts' => {
          '5000/tcp' => {}
        },
        'HostConfig' => {
          'PortBindings' => { '5000/tcp' => [{ 'HostPort' => '5000' }] }
        }
      )
      registry.start
      Rake::Task["spec"].invoke
    ensure
      registry.kill!.remove unless registry.nil?
    end
  end
end

desc 'Pull an Ubuntu image'
image 'ubuntu:13.10' do
  puts "Pulling ubuntu:13.10"
  image = Docker::Image.create('fromImage' => 'ubuntu', 'tag' => '13.10')
  puts "Pulled ubuntu:13.10, image id: #{image.id}"
end
