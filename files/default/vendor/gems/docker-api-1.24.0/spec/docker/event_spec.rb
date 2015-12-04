require 'spec_helper'

describe Docker::Event do
  describe "#to_s" do
    subject { described_class.new(status, id, from, time) }

    let(:status) { "start" }
    let(:id) { "398c9f77b5d2" }
    let(:from) { "debian:wheezy" }
    let(:time) { 1381956164 }

    let(:expected_string) {
      "Docker::Event { :status => #{status}, :id => #{id}, "\
      ":from => #{from}, :time => #{time.to_s} }"
    }

    it "equals the expected string" do
      expect(subject.to_s).to eq(expected_string)
    end
  end

  describe ".stream" do
    let(:container) { Docker::Image.create('fromImage' => 'debian:wheezy').run('bash') }
    it 'receives at least 4 events' do
      expect(Docker::Event)
        .to receive(:new_event)
        .at_least(4).times
        .and_call_original

      stream_thread = Thread.new do
        Docker::Event.stream do |event|
          puts "#{event}"
        end
      end

      stream_thread.join(0.1)
      container.wait
      stream_thread.join(10)
      stream_thread.kill

      container.remove
    end
  end

  describe ".since" do
    let(:time) { Time.now.to_i + 1 }
    let(:container) { Docker::Image.create('fromImage' => 'debian:wheezy').run('bash') }

    it 'receives at least 4 events' do
      expect(Docker::Event)
        .to receive(:new_event)
        .at_least(4).times
        .and_call_original

      stream_thread = Thread.new do
        Docker::Event.since(time) do |event|
          puts "#{event}"
        end
      end

      stream_thread.join(0.1)
      container.wait
      stream_thread.join(10)
      stream_thread.kill

      container.remove
    end
  end

  describe ".new_event" do
    subject { Docker::Event.new_event(response_body, nil, nil) }
    let(:status) { "start" }
    let(:id) { "398c9f77b5d2" }
    let(:from) { "debian:wheezy" }
    let(:time) { 1381956164 }
    let(:response_body) {
      "{\"status\":\"#{status}\",\"id\":\"#{id}\""\
      ",\"from\":\"#{from}\",\"time\":#{time}}"
    }

    it "returns a Docker::Event" do
      expect(subject).to be_kind_of(Docker::Event)
      expect(subject.status).to eq(status)
      expect(subject.id).to eq(id)
      expect(subject.from).to eq(from)
      expect(subject.time).to eq(time)
    end
  end
end
