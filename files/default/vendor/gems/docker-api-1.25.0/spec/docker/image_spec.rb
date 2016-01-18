require 'spec_helper'

describe Docker::Image do
  describe '#to_s' do
    subject { described_class.new(Docker.connection, info) }

    let(:id) { 'bf119e2' }
    let(:connection) { Docker.connection }

    let(:info) do
      {"id" => "bf119e2", "Repository" => "debian", "Tag" => "wheezy",
        "Created" => 1364102658, "Size" => 24653, "VirtualSize" => 180116135}
    end

    let(:expected_string) do
      "Docker::Image { :id => #{id}, :info => #{info.inspect}, "\
        ":connection => #{connection} }"
    end

    its(:to_s) { should == expected_string }
  end

  describe '#remove' do

    context 'when no name is given' do
      let(:id) { subject.id }
      subject { described_class.create('fromImage' => 'busybox:latest') }
      after { described_class.create('fromImage' => 'busybox:latest') }

      it 'removes the Image' do
        subject.remove(:force => true)
        expect(Docker::Image.all.map(&:id)).to_not include(id)
      end
    end

    context 'when a valid tag is given' do
      it 'untags the Image'
    end

    context 'when an invalid tag is given' do
      it 'raises an error'
    end
  end

  describe '#insert_local' do
    include_context "local paths"

    subject { described_class.create('fromImage' => 'debian:wheezy') }

    let(:rm) { false }
    let(:new_image) {
      opts = {'localPath' => file, 'outputPath' => '/'}
      opts[:rm] = true if rm
      subject.insert_local(opts)
    }

    context 'when the local file does not exist' do
      let(:file) { '/lol/not/a/file' }

      it 'raises an error' do
        expect { new_image }.to raise_error(Docker::Error::ArgumentError)
      end
    end

    context 'when the local file does exist' do
      let(:file) { File.join(project_dir, 'Gemfile') }
      let(:gemfile) { File.read('Gemfile') }
      let(:container) { new_image.run('cat /Gemfile').tap(&:wait) }
      after do
        container.remove
        new_image.remove
      end

      it 'creates a new Image that has that file' do
        output = container.streaming_logs(stdout: true)
        expect(output).to eq(gemfile)
      end
    end

    context 'when a direcory is passed' do
      let(:new_image) {
        subject.insert_local(
          'localPath' => File.join(project_dir, 'lib'),
          'outputPath' => '/lib'
        )
      }
      let(:container) { new_image.run('ls -a /lib/docker') }
      let(:response) { container.tap(&:wait).streaming_logs(stdout: true) }
      after do
        container.tap(&:wait).remove
        new_image.remove
      end

      it 'inserts the directory' do
        expect(response.split("\n").sort).to eq(Dir.entries('lib/docker').sort)
      end
    end

    context 'when there are multiple files passed' do
      let(:file) {
        [File.join(project_dir, 'Gemfile'), File.join(project_dir, 'LICENSE')]
      }
      let(:gemfile) { File.read('Gemfile') }
      let(:license) { File.read('LICENSE') }
      let(:container) { new_image.run('cat /Gemfile /LICENSE') }
      let(:response) {
        container.tap(&:wait).streaming_logs(stdout: true)
      }
      after do
        container.remove
        new_image.remove
      end

      it 'creates a new Image that has each file' do
        expect(response).to eq("#{gemfile}#{license}")
      end
    end

    context 'when removing intermediate containers' do
      let(:rm) { true }
      let(:file) { File.join(project_dir, 'Gemfile') }
      after(:each) { new_image.remove }

      it 'leave no intermediate containers' do
        expect { new_image }.to change {
          Docker::Container.all(:all => true).count
        }.by 0
      end

      it 'creates a new image' do
        expect{new_image}.to change{Docker::Image.all.count}.by 1
      end
    end
  end

  describe '#push' do
    let(:credentials) {
      {
        'username' => ENV['DOCKER_API_USER'],
        'password' => ENV['DOCKER_API_PASS'],
        'serveraddress' => 'https://index.docker.io/v1',
        'email'    => ENV['DOCKER_API_EMAIL']
      }
    }
    let(:repo_tag) { "#{ENV['DOCKER_API_USER']}/true" }
    let(:image) {
      described_class.build("FROM tianon/true\n", "t" => repo_tag).refresh!
    }
    after { image.remove(:name => repo_tag, :noprune => true) }

    it 'pushes the Image' do
      image.push(credentials)
    end

    it 'streams output from push' do
      expect { |b| image.push(credentials, &b) }
        .to yield_control.at_least(1)
    end

    context 'when a tag is specified' do
      it 'pushes that specific tag'
    end

    context 'when the image was retrived by get' do
      let(:image) {
        described_class.build("FROM tianon/true\n", "t" => repo_tag).refresh!
        described_class.get(repo_tag)
      }

      context 'when no tag is specified' do
        it 'looks up the first repo tag' do
          expect { image.push }.to_not raise_error
        end
      end
    end

    context 'when there are no credentials' do
      let(:credentials) { nil }
      let(:repo_tag) { "localhost:5000/true" }

      it 'still pushes' do
        expect { image.push }.to_not raise_error
      end
    end
  end

  describe '#tag' do
    subject { described_class.create('fromImage' => 'debian:wheezy') }
    after { subject.remove(:name => 'teh:latest', :noprune => true) }

    it 'tags the image with the repo name' do
      subject.tag(:repo => :teh, :force => true)
      expect(subject.info['RepoTags']).to include 'teh:latest'
    end
  end

  describe '#json' do
    subject { described_class.create('fromImage' => 'debian:wheezy') }
    let(:json) { subject.json }

    it 'returns additional information about image image' do
      expect(json).to be_a Hash
      expect(json.length).to_not be_zero
    end
  end

  describe '#history' do
    subject { described_class.create('fromImage' => 'debian:wheezy') }
    let(:history) { subject.history }

    it 'returns the history of the Image' do
      expect(history).to be_a Array
      expect(history.length).to_not be_zero
      expect(history).to be_all { |elem| elem.is_a? Hash }
    end
  end

  describe '#run' do
    subject { described_class.create('fromImage' => 'debian:wheezy') }
    let(:container) { subject.run(cmd).tap(&:wait) }
    let(:output) { container.streaming_logs(stdout: true) }

    context 'when the argument is a String' do
      let(:cmd) { 'ls /lib64/' }
      after { container.remove }

      it 'splits the String by spaces and creates a new Container' do
        expect(output).to eq("ld-linux-x86-64.so.2\n")
      end
    end

    context 'when the argument is an Array' do
      let(:cmd) { %w[which pwd] }
      after { container.remove }

      it 'creates a new Container' do
        expect(output).to eq("/bin/pwd\n")
      end
    end

    context 'when the argument is nil'  do
      let(:cmd) { nil }
      context 'no command configured in image' do
        subject { described_class.create('fromImage' => 'swipely/base') }
        it 'should raise an error if no command is specified' do
          expect {container}.to raise_error(Docker::Error::ServerError,
                                         "No command specified.")
        end
      end

      context "command configured in image" do
        let(:cmd) { 'pwd' }
        after { container.remove }

        it 'should normally show result if image has Cmd configured' do
          expect(output).to eql "/\n"
        end
      end
    end
  end

  describe '#save' do
    let(:image) { Docker::Image.get('busybox') }

    it 'calls the class method' do
      expect(Docker::Image).to receive(:save)
        .with(image.id, 'busybox.tar', anything)
      image.save('busybox.tar')
    end
  end

  describe '#refresh!' do
    let(:image) { Docker::Image.create('fromImage' => 'debian:wheezy') }

    it 'updates the @info hash' do
      size = image.info.size
      image.refresh!
      expect(image.info.size).to be > size
    end

    context 'with an explicit connection' do
      let(:connection) { Docker::Connection.new(Docker.url, Docker.options) }
      let(:image) {
        Docker::Image.create({'fromImage' => 'debian:wheezy'}, nil, connection)
      }

      it 'updates using the provided connection' do
        image.refresh!
      end
    end
  end

  describe '.create' do
    subject { described_class }

    context 'when the Image does not yet exist and the body is a Hash' do
      let(:image) { subject.create('fromImage' => 'swipely/base') }
      let(:creds) {
        {
          :username => ENV['DOCKER_API_USER'],
          :password => ENV['DOCKER_API_PASS'],
          :email => ENV['DOCKER_API_EMAIL']
        }
      }

      before do
        Docker::Image.create('fromImage' => 'swipely/base').remove
      end
      after { Docker::Image.create('fromImage' => 'swipely/base') }

      it 'sets the id and sends Docker.creds' do
        allow(Docker).to receive(:creds).and_return(creds)
        expect(image).to be_a Docker::Image
        expect(image.id).to match(/\A[a-fA-F0-9]+\Z/)
        expect(image.id).to_not include('base')
        expect(image.id).to_not be_nil
        expect(image.id).to_not be_empty
      end
    end

    context 'with a block capturing create output' do
      let(:create_output) { "" }
      let(:block) { Proc.new { |chunk| create_output << chunk } }

      before do
        Docker.creds = nil
        subject.create('fromImage' => 'tianon/true').remove
      end

      it 'calls the block and passes build output' do
        subject.create('fromImage' => 'tianon/true', &block)
        expect(create_output).to match(/Pulling.*tianon\/true/)
      end
    end
  end

  describe '.get' do
    subject { described_class }
    let(:image) { subject.get(image_name) }

    context 'when the image does exist' do
      let(:image_name) { 'debian:wheezy' }

      it 'returns the new image' do
        expect(image).to be_a Docker::Image
      end
    end

    context 'when the image does not exist' do
      let(:image_name) { 'abcdefghijkl' }

      before do
        Docker.options = { :mock => true }
        Excon.stub({ :method => :get }, { :status => 404 })
      end

      after do
        Docker.options = {}
        Excon.stubs.shift
      end

      it 'raises a not found error' do
        expect { image }.to raise_error(Docker::Error::NotFoundError)
      end
    end
  end

  describe '.save' do
    include_context "local paths"

    context 'when a filename is specified' do
      let(:file) { "#{project_dir}/scratch.tar" }
      after { FileUtils.remove(file) }

      it 'exports tarball of image to specified file' do
        Docker::Image.save('swipely/base', file)
        expect(File.exist?(file)).to eq true
        expect(File.read(file)).to_not be_nil
      end
    end

    context 'when no filename is specified' do
      it 'returns raw binary data as string' do
        raw = Docker::Image.save('swipely/base')
        expect(raw).to_not be_nil
      end
    end
  end

  describe '.exist?' do
    subject { described_class }
    let(:exists) { subject.exist?(image_name) }

    context 'when the image does exist' do
      let(:image_name) { 'debian:wheezy' }

      it 'returns true' do
        expect(exists).to eq(true)
      end
    end

    context 'when the image does not exist' do
      let(:image_name) { 'abcdefghijkl' }

      before do
        Docker.options = { :mock => true }
        Excon.stub({ :method => :get }, { :status => 404 })
      end

      after do
        Docker.options = {}
        Excon.stubs.shift
      end

      it 'return false' do
        expect(exists).to eq(false)
      end
    end
  end

  describe '.import' do
    include_context "local paths"

    subject { described_class }

    context 'when the file does not exist' do
      let(:file) { '/lol/not/a/file' }

      it 'raises an error' do
        expect { subject.import(file) }
          .to raise_error(Docker::Error::IOError)
      end
    end

    context 'when the file does exist' do
      let(:file) { File.join(project_dir, 'spec', 'fixtures', 'export.tar') }
      let(:import) { subject.import(file) }
      after { import.remove(:noprune => true) }

      it 'creates the Image' do
        expect(import).to be_a Docker::Image
        expect(import.id).to_not be_nil
      end
    end

    context 'when the argument is a URI' do
      context 'when the URI is invalid' do
        it 'raises an error' do
          expect { subject.import('http://google.com') }
            .to raise_error(Docker::Error::IOError)
        end
      end

      context 'when the URI is valid' do
        let(:uri) { 'http://swipely-pub.s3.amazonaws.com/tianon_true.tar' }
        let(:import) { subject.import(uri) }
        after { import.remove(:noprune => true) }

        it 'returns an Image' do
          expect(import).to be_a Docker::Image
          expect(import.id).to_not be_nil
        end
      end
    end
  end

  describe '.all' do
    subject { described_class }

    let(:images) { subject.all(:all => true) }
    before { subject.create('fromImage' => 'debian:wheezy') }

    it 'materializes each Image into a Docker::Image' do
      images.each do |image|
        expect(image).to_not be_nil

        expect(image).to be_a(described_class)

        expect(image.id).to_not be_nil

        %w(Created Size VirtualSize).each do |key|
          expect(image.info).to have_key(key)
        end
      end

      expect(images.length).to_not be_zero
    end
  end

  describe '.search' do
    subject { described_class }

    it 'materializes each Image into a Docker::Image' do
      expect(subject.search('term' => 'sshd')).to be_all { |image|
        !image.id.nil? && image.is_a?(described_class)
      }
    end
  end

  describe '.build' do
    subject { described_class }
    context 'with an invalid Dockerfile' do
      it 'throws a UnexpectedResponseError' do
        expect { subject.build('lololol') }
            .to raise_error(Docker::Error::UnexpectedResponseError)
      end
    end

    context 'with a valid Dockerfile' do
      context 'without query parameters' do
        let(:image) { subject.build("FROM debian:wheezy\n") }

        it 'builds an image' do
          expect(image).to be_a Docker::Image
          expect(image.id).to_not be_nil
          expect(image.connection).to be_a Docker::Connection
        end
      end

      context 'with specifying a repo in the query parameters' do
        let(:image) {
          subject.build(
            "FROM debian:wheezy\nRUN true\n",
            "t" => "#{ENV['DOCKER_API_USER']}/debian:true"
          )
        }
        after { image.remove(:noprune => true) }

        it 'builds an image and tags it' do
          expect(image).to be_a Docker::Image
          expect(image.id).to_not be_nil
          expect(image.connection).to be_a Docker::Connection
          image.refresh!
          expect(image.info["RepoTags"]).to eq(
            ["#{ENV['DOCKER_API_USER']}/debian:true"]
          )
        end
      end

      context 'with a block capturing build output' do
        let(:build_output) { "" }
        let(:block) { Proc.new { |chunk| build_output << chunk } }
        let!(:image) { subject.build("FROM debian:wheezy\n", &block) }

        it 'calls the block and passes build output' do
          expect(build_output).to match(/Step \d : FROM debian:wheezy/)
        end
      end
    end
  end

  describe '.build_from_dir' do
    subject { described_class }

    context 'with a valid Dockerfile' do
      let(:dir) {
        File.join(File.dirname(__FILE__), '..', 'fixtures', 'build_from_dir')
      }
      let(:docker_file) { File.new("#{dir}/Dockerfile") }
      let(:image) { subject.build_from_dir(dir, opts, &block) }
      let(:opts) { {} }
      let(:block) { Proc.new {} }
      let(:container) do
        Docker::Container.create(
          'Image' => image.id,
          'Cmd' => %w[cat /Dockerfile]
        ).tap(&:start).tap(&:wait)
      end
      let(:output) { container.streaming_logs(stdout: true) }

      after(:each) do
        container.remove
        image.remove(:noprune => true)
      end

      context 'with no query parameters' do
        it 'builds the image' do
          expect(output).to eq(docker_file.read)
        end
      end

      context 'with specifying a repo in the query parameters' do
        let(:opts) { { "t" => "#{ENV['DOCKER_API_USER']}/debian:from_dir" } }
        it 'builds the image and tags it' do
          expect(output).to eq(docker_file.read)
          image.refresh!
          expect(image.info["RepoTags"]).to eq(
            ["#{ENV['DOCKER_API_USER']}/debian:from_dir"]
          )
        end
      end

      context 'with a block capturing build output' do
        let(:build_output) { "" }
        let(:block) { Proc.new { |chunk| build_output << chunk } }

        it 'calls the block and passes build output' do
          image # Create the image variable, which is lazy-loaded by Rspec
          expect(build_output).to match(/Step \d : FROM debian:wheezy/)
        end

        context 'uses a cached version the second time' do
          let(:build_output_two) { "" }
          let(:block_two) { Proc.new { |chunk| build_output_two << chunk } }
          let(:image_two) { subject.build_from_dir(dir, opts, &block_two) }

          it 'calls the block and passes build output' do
            image # Create the image variable, which is lazy-loaded by Rspec
            expect(build_output).to match(/Step \d : FROM debian:wheezy/)
            expect(build_output).to_not match(/Using cache/)

            image_two # Create the image_two variable, which is lazy-loaded by Rspec
            expect(build_output_two).to match(/Using cache/)
          end
        end
      end

      context 'with credentials passed' do
        let(:creds) {
          {
            :username => ENV['DOCKER_API_USER'],
            :password => ENV['DOCKER_API_PASS'],
            :email => ENV['DOCKER_API_EMAIL'],
            :serveraddress => 'https://index.docker.io/v1'
          }
        }

        before { Docker.creds = creds }
        after { Docker.creds = nil }

        it 'sends X-Registry-Config header' do
          expect(image.info[:headers].keys).to include('X-Registry-Config')
        end
      end
    end
  end
end
