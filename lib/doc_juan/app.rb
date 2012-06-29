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

    error DocJuan::Pdf::CouldNotGeneratePdfError do
      if defined? Airbrake
        error = request.env['sinatra.error']
        Airbrake.notify(
          error_class: error.class.to_s,
          error_message: "#{error.class}: #{error.message}",
          parameters: request.params
        )
      end
      halt 500, 'Could not generate the PDF'
    end

    # render a html page to a document
    get '/render' do
      pdf = DocJuan::Pdf.new params[:url], params[:filename], params[:options]
      result = pdf.generate

      headers['Content-Type'] = result.mime_type
      headers['Content-Disposition'] = "attachment; filename=\"#{result.filename}\""
      headers['Cache-Control'] = 'public,max-age=2592000'
      headers['X-Accel-Redirect'] = result.path
    end
  end
end
