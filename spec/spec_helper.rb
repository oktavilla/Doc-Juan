ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'
require 'ostruct'
require 'active_support/all'

MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new

require_relative '../lib/doc_juan/logger'
DocJuan.logger = Logger.new '/dev/null'
