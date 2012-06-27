require_relative './spec_helper'
require 'mocha'
require_relative '../lib/doc_juan/auth'

describe DocJuan::Auth do

  before :each do
    DocJuan.stubs(:config).returns(secret: 'zecret')
  end

  it 'has a secret' do
    DocJuan::Auth.new.secret.must_equal 'zecret'
  end

  it 'is initialized with a hash of params' do
    params = { a: 1 }
    auth = DocJuan::Auth.new params

    auth.params.must_equal params
  end

  it 'prepares params by flattening and sorting' do
    params = { 'b' => { 'c' => 2 }, 'a' => 1,  }
    auth = DocJuan::Auth.new params

    auth.prepared_params.must_equal({ 'a' => 1, 'b_c' => 2 })
  end

  it 'creates a message based' do
    params = { 'kittehz' => 'please', 'hello' => 'there' }
    auth = DocJuan::Auth.new params

    auth.message.must_equal 'hello:there-kittehz:please'
  end

  it 'creates a digest' do
    params = { 'kittehz' => 'please', 'hello' => 'there' }
    auth = DocJuan::Auth.new params

    auth.digest.must_equal 'd4578fb8a45470da81e5f1df54ce4e70d8f1cdbf'
  end

  describe 'verifying request' do

    it 'returns true if valid' do
      request = OpenStruct.new(params: { 'kittehz' => 'please',
                                         'hello' => 'there',
                                         'key' => 'd4578fb8a45470da81e5f1df54ce4e70d8f1cdbf' })

      DocJuan::Auth.valid_request?(request).must_equal true
    end

    it 'returns false if invalid' do
      request = OpenStruct.new(params: { 'kittehz' => 'please',
                                         'hello' => 'there',
                                         'key' => 'wrong key' })

      DocJuan::Auth.valid_request?(request).must_equal false
    end

  end

end
