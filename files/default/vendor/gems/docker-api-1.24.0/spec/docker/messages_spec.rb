require 'spec_helper'

describe Docker::Messages do
  shared_examples_for "two equal messages" do
    it "has the same messages as we expect" do
      expect(messages.all_messages).to eq(expected.all_messages)
      expect(messages.stdout_messages).to eq(expected.stdout_messages)
      expect(messages.stderr_messages).to eq(expected.stderr_messages)
      expect(messages.buffer).to eq(expected.buffer)
    end
  end

  describe '.decipher_messages' do
    shared_examples_for "decipher_messages of raw_test" do
      let(:messages) {
        subject.decipher_messages(raw_text)
      }

      it_behaves_like "two equal messages"
    end

    context 'given both standard out and standard error' do
      let(:raw_text) {
        "\x01\x00\x00\x00\x00\x00\x00\x01a\x02\x00\x00\x00\x00\x00\x00\x01b"
      }
      let(:expected) {
        Docker::Messages.new(["a"], ["b"], ["a","b"], "")
      }

      it_behaves_like "decipher_messages of raw_test"
    end

    context 'given a single header' do
      let(:raw_text) { "\x01\x00\x00\x00\x00\x00\x00\x01a" }
      let(:expected) {
        Docker::Messages.new(["a"], [], ["a"], "")
      }

      it_behaves_like "decipher_messages of raw_test"
    end

    context 'given two headers' do
      let(:raw_text) {
        "\x01\x00\x00\x00\x00\x00\x00\x01a\x01\x00\x00\x00\x00\x00\x00\x01b"
      }

      let(:expected) {
        Docker::Messages.new(["a", "b"], [], ["a","b"], "")
      }

      it_behaves_like "decipher_messages of raw_test"
    end

    context 'given a header for text longer then 255 characters' do
      let(:raw_text) {
        "\x01\x00\x00\x00\x00\x00\x01\x01" + ("a" * 257)
      }
      let(:expected) {
        Docker::Messages.new([("a" * 257)], [], [("a" * 257)], "")
      }

      it_behaves_like "decipher_messages of raw_test"
    end
  end

  describe "#append" do
    context "appending one set of messages on another" do
      let(:messages) {
        Docker::Messages.new([], [], [], "")
      }

      before do
        messages.append(new_messages)
      end

      context "with a buffer" do
        let(:new_messages) {
          Docker::Messages.new(["a"], [], ["a"], "b")
        }
        let(:expected) {
          Docker::Messages.new(["a"], [], ["a"], "")
        }
        it_behaves_like "two equal messages"
      end

      context "without a buffer" do
        let(:new_messages) {
          Docker::Messages.new(["a"], [], ["a"], "")
        }
        let(:expected) {
          Docker::Messages.new(["a"], [], ["a"], "")
        }
        it_behaves_like "two equal messages"
      end
    end
  end
end
