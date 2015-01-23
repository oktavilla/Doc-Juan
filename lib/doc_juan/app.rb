require 'sinatra/base'
require 'rack/sendfile'
require_relative 'auth'

module DocJuan
  class App < Sinatra::Base
    use Rack::Sendfile

    enable :logging

    before '/render*' do
      halt 401, 'Invalid key' unless DocJuan::Auth.valid_request?(request)
    end

    # empty page on index
    get '/' do
    end

    error DocJuan::CouldNotGenerateFileError do
      if defined? Airbrake
        error = request.env['sinatra.error']
        Airbrake.notify(
          error_class: error.class.to_s,
          error_message: "#{error.class}: #{error.message}",
          parameters: request.params
        )
      end
      halt 500, 'Could not generate file'
    end

    # render a html page to a document
    get '/render' do
      renderer_class = DocJuan.renderer params[:format]
      renderer = renderer_class.new params[:url], params[:filename], params[:options]
      result = renderer.generate

      cache_control :public, max_age: 2592000
      send_file result.path, type: result.mime_type, disposition: :inline, filename: result.filename
    end

    get '/robots.txt' do
      headers['Content-Type'] = "text/plain"

      "User-agent: *\nDisallow: /"
    end
  end
end
