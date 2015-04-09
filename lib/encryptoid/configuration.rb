module Encryptoid
  class Configuration
    attr_accessor :aes_salt

    def initialize
      @aes_salt = '1234567890'
    end

  end
end