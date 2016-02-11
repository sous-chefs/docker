require 'spec_helper'

describe Docker::Volume, :docker_1_9 do
  let(:name) { "ArbitraryNameForTheRakeTestVolume" }

  describe '.create' do
    let(:volume) { Docker::Volume.create(name) }

    after { volume.remove }

    it 'creates a volume' do
      expect(volume.id).to eq(name)
    end
  end

  describe '.get' do
    let(:volume) { Docker::Volume.get(name) }

    before { Docker::Volume.create(name) }
    after { volume.remove }

    it 'gets volume details' do
      expect(volume.id).to eq(name)
      expect(volume.info).to_not be_empty
    end
  end

  describe '.all' do
    after { Docker::Volume.get(name).remove }

    it 'gets a list of volumes' do
      expect { Docker::Volume.create(name) }.to change { Docker::Volume.all.length }.by(1)
    end
  end

  describe '#remove' do
    it 'removes a volume' do
      volume = Docker::Volume.create(name)
      expect { volume.remove }.to change { Docker::Volume.all.length }.by(-1)
    end
  end

end
