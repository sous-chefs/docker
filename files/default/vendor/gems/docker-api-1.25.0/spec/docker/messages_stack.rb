require 'spec_helper'

describe Docker::MessagesStack do

  describe '#append' do
    context 'without limits' do |variable|
      it 'does not limit stack size by default' do
        data = ['foo', 'bar']
        msg = Docker::Messages.new(data, [], data)
        expect(subject.messages).not_to receive(:shift)
        1000.times { subject.append(msg) }
      end
    end

    context 'with size limit' do
      let(:subject) { described_class.new(100) }

      it 'limits stack to given size' do
        data = ['foo', 'bar']
        msg = Docker::Messages.new(data, [], data)
        expect(subject.messages).to receive(:shift).exactly(1900).times
        1000.times { subject.append(msg) }
      end
    end
  end
end
