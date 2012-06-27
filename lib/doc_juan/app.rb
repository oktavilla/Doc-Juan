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
      pdf = DocJuan::Pdf.new params[:url], params[:filename], params[:options]
      result = pdf.generate
      if result.ok?
        headers['Content-Type'] = result.mime_type
        headers['Content-Disposition'] = "attachment; filename=\"#{result.filename}\""
        headers['X-Accel-Redirect'] = result.path
      end
    end
  end
end

