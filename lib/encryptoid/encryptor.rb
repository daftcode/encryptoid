module Encryptoid
  AES_ALGORITHM = 'aes-256-cbc'

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  # Encrypts data
  # @return encrypted_string, init vector
  def self.encrypt(data, options = {})
    crypt! data, options.merge(mode: :encrypt)
  end

  # Decrypts data
  # @return decrypted_string, init vector
  def self.decrypt(data, options = {})
    crypt! data, options.merge(mode: :decrypt)
  end

  # Opens a given path and encrypts file contents
  # i/o optimized using chunked processing
  def self.encrypt_file_in_chunks!(path, chunk_size = 2048, opts = {})
    file = File.open(path, 'r')
    tmp = Tempfile.new('file_encrypt')
    tmp.binmode
    cipher = init_cipher opts.merge(mode: :encrypt)
    while (chunk = file.read(chunk_size))
      tmp << cipher.update(chunk)
    end
    tmp << cipher.final
    tmp.flush
    FileUtils.cp tmp.path, path
    tmp.unlink
  end

  # Opens a given path and decrypts contents
  # @return decrypted data as String
  def self.decrypt_file(path, options = {})
    encrypted = File.open(path, 'rb', &:read)
    decrypt encrypted, options
  end

  def self.random_key
    OpenSSL::Random.random_bytes(256)
  end

  def self.crypt!(data, opts = {})
    cipher = init_cipher opts
    cipher.padding = 0
    result = cipher.update data
    result << cipher.final
  end

  private_class_method :crypt!

  def self.init_cipher(opts)
    [:key, :iv, :mode].each { |arg| raise ArgumentError.new("must specify a #{arg}") if opts[arg].to_s.empty? }
    OpenSSL::Cipher.new(AES_ALGORITHM).tap do |cipher|
      cipher.send(opts[:mode])
      iv = opts[:iv] || cipher.random_iv
      cipher.iv = iv
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1 opts[:key], configuration.aes_salt, 2000, cipher.key_len
    end
  end

  private_class_method :init_cipher
end
