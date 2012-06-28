ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

if ENV['AIRBRAKE_API_KEY']
  require 'airbrake'

  Airbrake.configure do |config|
    config.api_key = ENV['AIRBRAKE_API_KEY']
  end

  use Airbrake::Rack
end

require File.expand_path('../lib/doc_juan', __FILE__)

run DocJuan::App
