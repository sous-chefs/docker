require 'spec_helper'

describe Docker::Exec do
  let(:container) {
    Docker::Container.create(
      'Cmd' => %w(sleep 300),
      'Image' => 'debian:wheezy'
    ).start!
  }

  describe '#to_s' do
    subject {
      described_class.send(:new, Docker.connection, 'id' => rand(10000).to_s)
    }

    let(:id) { 'bf119e2' }
    let(:connection) { Docker.connection }
    let(:expected_string) {
      "Docker::Exec { :id => #{id}, :connection => #{connection} }"
    }
    before do
      {
        :@id => id,
        :@connection => connection
      }.each { |k, v| subject.instance_variable_set(k, v) }
    end

    its(:to_s) { should == expected_string }
  end

  describe '.create' do
    subject { described_class }

    context 'when the HTTP request returns a 201' do
      let(:options) do
        {
          'AttachStdin' => false,
          'AttachStdout' => false,
          'AttachStderr' => false,
          'Tty' => false,
          'Cmd' => [
            'date'
          ],
          'Container' => container.id
        }
      end
      let(:process) { subject.create(options) }
      after { container.kill!.remove }

      it 'sets the id' do
        expect(process).to be_a Docker::Exec
        expect(process.id).to_not be_nil
        expect(process.connection).to_not be_nil
      end
    end

    context 'when the parent container does not exist' do
      before do
        Docker.options = { :mock => true }
        Excon.stub({ :method => :post }, { :status => 404 })
      end
      after do
        Excon.stubs.shift
        Docker.options = {}
      end

      it 'raises an error' do
        expect { subject.create }.to raise_error(Docker::Error::NotFoundError)
      end
    end
  end

  describe '#json' do
    subject {
      described_class.create(
        'Container' => container.id,
        'Detach' => true,
        'Cmd' => %w[true]
      )
    }

    let(:description) { subject.json }
    before { subject.start! }
    after { container.kill!.remove }

    it 'returns the description as a Hash' do
      expect(description).to be_a Hash
      expect(description['ID']).to start_with(subject.id)
    end
  end

  describe '#start!' do
    context 'when the exec instance does not exist' do
      subject do
        described_class.send(:new, Docker.connection, 'id' => rand(10000).to_s)
      end

      it 'raises an error' do
        expect { subject.start! }.to raise_error(Docker::Error::NotFoundError)
      end
    end

    context 'when :detach is set to false' do
      subject {
        described_class.create(
          'Container' => container.id,
          'AttachStdout' => true,
          'Cmd' => ['bash','-c','sleep 2; echo hello']
        )
      }
      after { container.kill!.remove }

      it 'returns the stdout and stderr messages' do
        expect(subject.start!).to eq([["hello\n"],[],0])
      end

      context 'block is passed' do
        it 'attaches to the stream' do
          chunk = nil
          result = subject.start! do |stream, c|
            chunk ||= c
          end
          expect(chunk).to eq("hello\n")
          expect(result).to eq([["hello\n"], [], 0])
        end
      end
    end

    context 'when :detach is set to true' do
      subject {
        described_class.create('Container' => container.id, 'Cmd' => %w[date])
      }
      after { container.kill!.remove }

      it 'returns empty stdout/stderr messages with exitcode' do
        expect(subject.start!(:detach => true)).to eq([[],[], 0])
      end
    end

    context 'when :wait set long time value' do
      subject {
        described_class.create('Container' => container.id, 'Cmd' => %w[date])
      }
      after { container.kill!.remove }

      it 'returns empty stdout and stderr messages with exitcode' do
        expect(subject.start!(:wait => 100)).to eq([[], [], 0])
      end
    end

    context 'when :wait set short time value' do
      subject {
        described_class.create(
            'Container'    => container.id,
            'AttachStdout' => true,
            'Cmd'          => ['bash', '-c', 'sleep 2; echo hello']
        )
      }
      after { container.kill!.remove }

      it 'raises an error' do
        expect { subject.start!(:wait => 1) }.to raise_error(Docker::Error::TimeoutError)
      end
    end

    context 'when the HTTP request returns a 201' do
      subject {
        described_class.create('Container' => container.id, 'Cmd' => ['date'])
      }
      after { container.kill!.remove }

      it 'starts the exec instance' do
        expect { subject.start! }.not_to raise_error
      end
    end
  end
end
