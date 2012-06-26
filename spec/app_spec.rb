require_relative './spec_helper'
require 'rack/test'

require_relative '../lib/doc_juan/app.rb'

describe 'DocJuan' do
  include Rack::Test::Methods

  def app
    DocJuan::App
  end

  describe '/' do

    it 'renders an empty 200 page' do
      get '/'
      last_response.ok?.must_equal true
      last_response.body.must_be :empty?
    end

  end

  describe '/render' do

    before do
      ENV['DOC_JUAN_SECRET'] = 'zecret'
    end

    describe 'requires a valid key' do

      it 'returns a 401 (Unauthorized) when key is invalid' do
        get '/render?url=a&filename=b&key=c'
        last_response.status.must_equal 401
      end

      it 'returns a 200 (OK) when key is valid' do
        get '/render?url=a&filename=b&key=99b4095fc31c5fbd012252b35e579807c280bb7c'
        last_response.status.must_equal 200
      end

    end

  end

end
