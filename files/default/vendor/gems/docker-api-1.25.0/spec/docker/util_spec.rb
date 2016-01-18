require 'spec_helper'

describe Docker::Util do
  subject { described_class }

  describe '.parse_json' do
    subject { described_class.parse_json(arg) }

    context 'when the argument is nil' do
      let(:arg) { nil }

      it { should be_nil }
    end

    context 'when the argument is empty' do
      let(:arg) { '' }

      it { should be_nil }
    end

    context 'when the argument is \'null\'' do
      let(:arg) { 'null' }

      it { should be_nil }
    end

    context 'when the argument is not valid JSON' do
      let(:arg) { '~~lol not valid json~~' }

      it 'raises an error' do
        expect { subject }.to raise_error Docker::Error::UnexpectedResponseError
      end
    end

    context 'when the argument is valid JSON' do
      let(:arg) { '{"yolo":"swag"}' }

      it 'parses the JSON into a Hash' do
        expect(subject).to eq 'yolo' => 'swag'
      end
    end
  end

  describe '.fix_json' do
    let(:response) { '{"this":"is"}{"not":"json"}' }
    subject { Docker::Util.fix_json(response) }

    it 'fixes the "JSON" response that Docker returns' do
      expect(subject).to eq [
        {
          'this' => 'is'
        },
        {
          'not' => 'json'
        }
      ]
    end
  end

  describe '.create_dir_tar' do
    attr_accessor :tmpdir

    around do |example|
      Dir.mktmpdir do |tmpdir|
        self.tmpdir = tmpdir
        example.call
      end
    end

    specify do
      tar = subject.create_dir_tar tmpdir
      expect { FileUtils.rm tar }.to_not raise_error
    end
  end

  describe '.build_auth_header' do
    subject { described_class }

    let(:credentials) {
      {
        :username      => 'test',
        :password      => 'password',
        :email         => 'test@example.com',
        :serveraddress => 'https://registry.com/'
      }
    }
    let(:credential_string) { credentials.to_json }
    let(:encoded_creds) { Base64.encode64(credential_string).gsub(/\n/, '') }
    let(:expected_header) {
      {
        'X-Registry-Auth' => encoded_creds
      }
    }


    context 'given credentials as a Hash' do
      it 'returns an X-Registry-Auth header encoded' do
        expect(subject.build_auth_header(credentials)).to eq(expected_header)
      end
    end

    context 'given credentials as a String' do
      it 'returns an X-Registry-Auth header encoded' do
        expect(
          subject.build_auth_header(credential_string)
        ).to eq(expected_header)
      end
    end
  end

  describe '.build_config_header' do
    subject { described_class }

    let(:credentials) {
      {
        :username      => 'test',
        :password      => 'password',
        :email         => 'test@example.com',
        :serveraddress => 'https://registry.com/'
      }
    }

    let(:credentials_object) {
      {
        :configs => {
          :'https://registry.com/' => {
            :username => 'test',
            :password => 'password',
            :email    => 'test@example.com',
          }
        }
      }.to_json
    }

    let(:encoded_creds) { Base64.encode64(credentials_object).gsub(/\n/, '') }
    let(:expected_header) {
      {
        'X-Registry-Config' => encoded_creds
      }
    }

    context 'given credentials as a Hash' do
      it 'returns an X-Registry-Config header encoded' do
        expect(subject.build_config_header(credentials)).to eq(expected_header)
      end
    end

    context 'given credentials as a String' do
      it 'returns an X-Registry-Config header encoded' do
        expect(
          subject.build_config_header(credentials.to_json)
        ).to eq(expected_header)
      end
    end
  end
end
