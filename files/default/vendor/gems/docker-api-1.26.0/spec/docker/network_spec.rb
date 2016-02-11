require 'spec_helper'

describe Docker::Network, docker_1_9: true do
  let(:name) do |example|
    example.description.downcase.gsub('\s', '-')
  end

  describe '#to_s' do
    subject { described_class.new(Docker.connection, info) }
    let(:connection) { Docker.connection }

    let(:id) do
      'a6c5ffd25e07a6c906accf804174b5eb6a9d2f9e07bccb8f5aa4f4de5be6d01d'
    end

    let(:info) do
      {
        'Name' => 'bridge',
        'Scope' => 'local',
        'Driver' => 'bridge',
        'IPAM' => {
          'Driver' => 'default',
          'Config' => [{ 'Subnet' => '172.17.0.0/16' }]
        },
        'Containers' => {},
        'Options' => {
          'com.docker.network.bridge.default_bridge' => 'true',
          'com.docker.network.bridge.enable_icc' => 'true',
          'com.docker.network.bridge.enable_ip_masquerade' => 'true',
          'com.docker.network.bridge.host_binding_ipv4' => '0.0.0.0',
          'com.docker.network.bridge.name' => 'docker0',
          'com.docker.network.driver.mtu' => '1500'
        },
        'id' => id
      }
    end

    let(:expected_string) do
      "Docker::Network { :id => #{id}, :info => #{info.inspect}, "\
        ":connection => #{connection} }"
    end

    its(:to_s) { should == expected_string }
  end

  describe '.create' do
    let!(:id) { subject.id }
    subject { described_class.create(name) }
    after { described_class.remove(id) }

    it 'creates a Network' do
      expect(Docker::Network.all.map(&:id)).to include(id)
    end
  end

  describe '.remove' do
    let(:id) { subject.id }
    subject { described_class.create(name) }

    it 'removes the Network' do
      described_class.remove(id)
      expect(Docker::Network.all.map(&:id)).to_not include(id)
    end
  end

  describe '.get' do
    after do
      described_class.remove(name)
    end

    let!(:network) { described_class.create(name) }

    it 'returns a network' do
      expect(Docker::Network.get(name).id).to eq(network.id)
    end
  end

  describe '.all' do
    let!(:networks) do
      5.times.map { |i| described_class.create("#{name}-#{i}") }
    end

    after do
      networks.each(&:remove)
    end

    it 'should return all networks' do
      expect(Docker::Network.all.map(&:id)).to include(*networks.map(&:id))
    end
  end

  describe '#connect' do
    let!(:container) do
      Docker::Container.create(
        'Cmd' => %w(sleep 10),
        'Image' => 'debian:wheezy'
      )
    end
    subject { described_class.create(name) }

    before(:each) { container.start }
    after(:each) do
      container.kill!.remove
      subject.remove
    end

    it 'connects a container to a network' do
      subject.connect(container.id)
      expect(subject.info['Containers']).to include(container.id)
    end
  end

  describe '#disconnect' do
    let!(:container) do
      Docker::Container.create(
        'Cmd' => %w(sleep 10),
        'Image' => 'debian:wheezy'
      )
    end

    subject { described_class.create(name) }

    before(:each) do
      container.start
      sleep 1
      subject.connect(container.id)
    end

    after(:each) do
      container.kill!.remove
      subject.remove
    end

    it 'connects a container to a network' do
      subject.disconnect(container.id)
      expect(subject.info['Containers']).not_to include(container.id)
    end
  end

  describe '#remove' do
    let(:id) { subject.id }
    let(:name) { 'test-network-remove' }
    subject { described_class.create(name) }

    it 'removes the Network' do
      subject.remove
      expect(Docker::Network.all.map(&:id)).to_not include(id)
    end
  end
end
