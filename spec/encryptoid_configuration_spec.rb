require 'spec_helper'

describe Encryptoid::Configuration do
  describe '.aes_salt' do
    it 'has default value' do
      expect(subject.aes_salt).not_to be nil
    end
  end
end