# Encryptoid

Encryptoid uses OpenSSL to encrypt and decrypt data with a symmetric key.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'encryptoid', git: 'https://github.com/daftcode/encryptoid.git'
```

And then execute:

    $ bundle

## Configuration
Set a `salt` for AES encryption algorithm using a configuration block

    Encryptoid.configure do |config|
        config.aes_salt = '1234567890'
    end

## Usage

### Create an encryption key and initialization vector

    key = Encryptoid.random_key   # generate random key
    key = 'super_secret_key'      # or pass own key

    iv = OpenSSL::Cipher.new(Encryptoid::AES_ALGORITHM).random_iv

(remember to store your `key` and `iv` to be able to decrypt data)

### Encryption:

    Encryptoid.encrypt('private data', key: key, iv: iv)

### Decryption:

    Encryptoid.decrypt(encrypted_data, key: key, iv: iv)

### File encryption:

    Encryptoid.encrypt_file_in_chunks!('~/passwords.txt', chunk_size, key: key, iv: iv)

### File decryption:

    Encryptoid.decrypt_file('~/passwords.txt', key: key, iv: iv)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/encryptoid/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request