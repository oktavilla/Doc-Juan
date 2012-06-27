ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require File.expand_path('../lib/doc_juan', __FILE__)
run DocJuan::App
