require 'sinatra/base'
require_relative 'auth'

class DocJuan < Sinatra::Base

  before '/render*' do
    halt 401, 'Invalid key' unless Auth.valid_request?(request)
  end

  # empty page on index
  get '/' do
  end

  # render a html page to a document
  get '/render' do
  end
end
