require 'spec_helper'
require 'fakefs'

describe Encryptoid do
  it 'has a version number' do
    expect(Encryptoid::VERSION).not_to be nil
  end

  let(:content) { 'test1234' }
  let(:key) { '54316453D4537635C415234BA4983' }
  let(:options) { {key: key, iv: OpenSSL::Cipher.new('aes-256-cbc').random_iv} }

  context 'encrypts and decrypts' do
    it 'reads encoded contents' do
      encrypted_value = Encryptoid.encrypt(content, options)
      expect(Encryptoid.decrypt(encrypted_value, options)).to eq content
    end
  end

  context 'when a file exists' do
    let(:path) { 'spec/files/encryption_test' }

    before do
      FakeFS.activate!
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.mkdir_p('/tmp') # Incredible hack for Tempfiles in FakeFS
    end

    context 'encoding in chunks' do
      before do
        File.open(path, 'wb+') do |f|
          f.write content
        end
      end

      it 'can read encrypted contents' do
        Encryptoid.encrypt_file_in_chunks! path, 2, options
        data = Encryptoid.decrypt_file path, options

        expect(data).to eq content
      end
    end

    context 'encoding in one step' do
      before do
        @data = Encryptoid.encrypt content, options
        File.open(path, 'wb') do |f|
          f.write @data
        end
      end

      it 'reads file contents' do
        data = Encryptoid.decrypt_file(path, key: key, iv: options[:iv])
        expect(data).to eq content
      end
    end

    after do
      FakeFS.deactivate!
    end
  end

  context 'init validation' do
    let(:init_options) { options.merge(mode: :encrypt) }

    [:key, :mode, :iv].each do |required|
      it "raises error with missing #{required}" do
        init_options.delete(required)
        expect { Encryptoid.send(:init_cipher, options) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#configure' do
    let(:aes_salt) { 'test_salt' }

    before do
      Encryptoid.configure do |config|
        config.aes_salt = aes_salt
      end
    end

    it 'sets aes salt' do
      expect(Encryptoid.configuration.aes_salt).to eq aes_salt
    end
  end

  describe '#configuration' do
    it 'returns configuration object' do
      expect(Encryptoid.configuration).to be_a Encryptoid::Configuration
    end
  end

end
