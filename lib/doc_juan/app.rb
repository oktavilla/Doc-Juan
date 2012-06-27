require 'sinatra/base'
require_relative 'auth'

module DocJuan
  class App < Sinatra::Base

    before '/render*' do
      halt 401, 'Invalid key' unless DocJuan::Auth.valid_request?(request)
    end

    # empty page on index
    get '/' do
    end

    # render a html page to a document
    get '/render' do
    end
  end
end

