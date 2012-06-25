ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../lib/doc_juan.rb'

describe 'DocJuan' do
  include Rack::Test::Methods

  def app
    DocJuan
  end

  it 'renders an empty 200 page on /' do
    get '/'
    assert last_response.ok?
    assert_equal "", last_response.body
  end

end
