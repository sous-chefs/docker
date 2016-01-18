require 'spec_helper'

describe Docker do
  subject { Docker }

  it { should be_a Module }

  context 'default url and connection' do
    context "when the DOCKER_* ENV variables aren't set" do
      before do
        allow(ENV).to receive(:[]).with('DOCKER_URL').and_return(nil)
        allow(ENV).to receive(:[]).with('DOCKER_HOST').and_return(nil)
        allow(ENV).to receive(:[]).with('DOCKER_CERT_PATH').and_return(nil)
        Docker.reset!
      end
      after { Docker.reset! }

      its(:options) { should == {} }
      its(:url) { should == 'unix:///var/run/docker.sock' }
      its(:connection) { should be_a Docker::Connection }
    end

    context "when the DOCKER_* ENV variables are set" do
      before do
        allow(ENV).to receive(:[]).with('DOCKER_URL')
          .and_return('unixs:///var/run/not-docker.sock')
        allow(ENV).to receive(:[]).with('DOCKER_HOST').and_return(nil)
        allow(ENV).to receive(:[]).with('DOCKER_CERT_PATH').and_return(nil)
        Docker.reset!
      end
      after { Docker.reset! }

      its(:options) { should == {} }
      its(:url) { should == 'unixs:///var/run/not-docker.sock' }
      its(:connection) { should be_a Docker::Connection }
    end

    context "when the DOCKER_HOST is set and uses default tcp://" do
      before do
        allow(ENV).to receive(:[]).with('DOCKER_URL').and_return(nil)
        allow(ENV).to receive(:[]).with('DOCKER_HOST').and_return('tcp://')
        allow(ENV).to receive(:[]).with('DOCKER_CERT_PATH').and_return(nil)
        Docker.reset!
      end
      after { Docker.reset! }

      its(:options) { should == {} }
      its(:url) { should == 'tcp://localhost:2375' }
      its(:connection) { should be_a Docker::Connection }
    end

    context "when the DOCKER_HOST ENV variable is set" do
      before do
        allow(ENV).to receive(:[]).with('DOCKER_URL').and_return(nil)
        allow(ENV).to receive(:[]).with('DOCKER_HOST')
          .and_return('tcp://someserver:8103')
        allow(ENV).to receive(:[]).with('DOCKER_CERT_PATH').and_return(nil)
        Docker.reset!
      end
      after { Docker.reset! }

      its(:options) { should == {} }
      its(:url) { should == 'tcp://someserver:8103' }
      its(:connection) { should be_a Docker::Connection }
    end

    context "DOCKER_URL should take precedence over DOCKER_HOST" do
      before do
        allow(ENV).to receive(:[]).with('DOCKER_URL')
          .and_return('tcp://someotherserver:8103')
        allow(ENV).to receive(:[]).with('DOCKER_HOST')
          .and_return('tcp://someserver:8103')
        allow(ENV).to receive(:[]).with('DOCKER_CERT_PATH').and_return(nil)
        Docker.reset!
      end
      after { Docker.reset! }

      its(:options) { should == {} }
      its(:url) { should == 'tcp://someotherserver:8103' }
      its(:connection) { should be_a Docker::Connection }
    end

    context "when the DOCKER_CERT_PATH and DOCKER_HOST ENV variables are set" do
      before do
        allow(ENV).to receive(:[]).with('DOCKER_URL').and_return(nil)
        allow(ENV).to receive(:[]).with('DOCKER_HOST')
          .and_return('tcp://someserver:8103')
        allow(ENV).to receive(:[]).with('DOCKER_CERT_PATH')
          .and_return('/boot2dockert/cert/path')
        allow(ENV).to receive(:[]).with('DOCKER_SSL_VERIFY').and_return(nil)
        Docker.reset!
      end
      after { Docker.reset! }

      its(:options) {
        should == {
          client_cert: '/boot2dockert/cert/path/cert.pem',
          client_key: '/boot2dockert/cert/path/key.pem',
          ssl_ca_file: '/boot2dockert/cert/path/ca.pem',
          scheme: 'https'
        }
      }
      its(:url) { should == 'tcp://someserver:8103' }
      its(:connection) { should be_a Docker::Connection }
    end

    context "when the DOCKER_CERT_PATH and DOCKER_SSL_VERIFY ENV variables are set" do
      before do
        allow(ENV).to receive(:[]).with('DOCKER_URL').and_return(nil)
        allow(ENV).to receive(:[]).with('DOCKER_HOST')
          .and_return('tcp://someserver:8103')
        allow(ENV).to receive(:[]).with('DOCKER_CERT_PATH')
          .and_return('/boot2dockert/cert/path')
        allow(ENV).to receive(:[]).with('DOCKER_SSL_VERIFY')
          .and_return('false')
        Docker.reset!
      end
      after { Docker.reset! }

      its(:options) {
        should == {
          client_cert: '/boot2dockert/cert/path/cert.pem',
          client_key: '/boot2dockert/cert/path/key.pem',
          ssl_ca_file: '/boot2dockert/cert/path/ca.pem',
          scheme: 'https',
          ssl_verify_peer: false
        }
      }
      its(:url) { should == 'tcp://someserver:8103' }
      its(:connection) { should be_a Docker::Connection }
    end

  end

  describe '#reset_connection!' do
    before { subject.connection }
    it 'sets the @connection to nil' do
      expect { subject.reset_connection! }
          .to change { subject.instance_variable_get(:@connection) }
          .to nil
    end
  end

  [:options=, :url=].each do |method|
    describe "##{method}" do
      before { Docker.reset! }

      it 'calls #reset_connection!' do
        expect(subject).to receive(:reset_connection!)
        subject.public_send(method, nil)
      end
    end
  end

  describe '#version' do
    before { Docker.reset! }

    let(:expected) {
      %w[ApiVersion Arch GitCommit GoVersion KernelVersion Os Version]
    }

    let(:version) { subject.version }
    it 'returns the version as a Hash' do
      expect(version).to be_a Hash
      expect(version.keys.sort).to include(*expected)
    end
  end

  describe '#info' do
    before { Docker.reset! }

    let(:info) { subject.info }
    let(:keys) do
      %w(Containers Debug DockerRootDir Driver DriverStatus ExecutionDriver ID
         IPv4Forwarding Images IndexServerAddress InitPath InitSha1
         KernelVersion Labels MemTotal MemoryLimit NCPU NEventsListener NFd
         NGoroutines Name OperatingSystem SwapLimit)
    end

    it 'returns the info as a Hash' do
      expect(info).to be_a Hash
      expect(info.keys.sort).to include(*keys)
    end
  end

  describe '#authenticate!' do
    subject { described_class }

    let(:authentication) {
      subject.authenticate!(credentials)
    }

    after { Docker.creds = nil }

    context 'with valid credentials' do
      let(:credentials) {
        {
          :username      => ENV['DOCKER_API_USER'],
          :password      => ENV['DOCKER_API_PASS'],
          :email         => ENV['DOCKER_API_EMAIL'],
          :serveraddress => 'https://index.docker.io/v1/'
        }
      }

      it 'logs in and sets the creds' do
        expect(authentication).to be true
        expect(Docker.creds).to eq(credentials.to_json)
      end
    end

    context 'with invalid credentials' do
      let(:credentials) {
        {
          :username      => 'test',
          :password      => 'password',
          :email         => 'test@example.com',
          :serveraddress => 'https://index.docker.io/v1/'
        }
      }

      it "raises an error and doesn't set the creds" do
        expect {
          authentication
        }.to raise_error(Docker::Error::AuthenticationError)
        expect(Docker.creds).to be_nil
      end
    end
  end

  describe '#validate_version' do
    before { Docker.reset! }

    context 'when a Docker Error is raised' do
      before do
        allow(Docker).to receive(:info).and_raise(Docker::Error::ClientError)
      end

      it 'raises a Version Error' do
        expect { subject.validate_version! }
            .to raise_error(Docker::Error::VersionError)
      end
    end

    context 'when nothing is raised' do
      its(:validate_version!) { should be true }
    end
  end
end
