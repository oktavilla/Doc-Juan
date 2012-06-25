require 'spec_helper'

require_relative '../lib/auth'

describe 'Auth' do

  before do
    ENV['DOC_JUAN_SECRET'] = 'zecret'
  end

  it 'has a secret based on env variable DOC_JUAN_SECRET' do
    Auth.new.secret.must_equal 'zecret'
  end

  it 'is initialized with a hash of params' do
    params = { a: 1 }
    auth = Auth.new params

    auth.params.must_equal params
  end

  it 'prepares params by flattening and sorting' do
    params = { 'b' => { 'c' => 2 }, 'a' => 1,  }
    auth = Auth.new params

    auth.prepared_params.must_equal({ 'a' => 1, 'b_c' => 2 })
  end

  it 'creates a message based on params sorted by key name' do
    params = { 'kittehz' => 'please', 'hello' => 'there' }
    auth = Auth.new params

    auth.message.must_equal 'hello:there-kittehz:please'
  end

  it 'creates a digest' do
    params = { 'kittehz' => 'please', 'hello' => 'there' }
    auth = Auth.new params

    auth.digest.must_equal 'd4578fb8a45470da81e5f1df54ce4e70d8f1cdbf'
  end

  describe 'verifying request' do

    it 'returns true if valid' do
      request = OpenStruct.new(params: { 'kittehz' => 'please',
                                         'hello' => 'there',
                                         'key' => 'd4578fb8a45470da81e5f1df54ce4e70d8f1cdbf' })

      Auth.valid_request?(request).must_equal true
    end

    it 'returns false if invalid' do
      request = OpenStruct.new(params: { 'kittehz' => 'please',
                                         'hello' => 'there',
                                         'key' => 'wrong key' })

      Auth.valid_request?(request).must_equal false
    end

  end

end
