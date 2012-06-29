require 'benchmark'

module DocJuan
  class << self
    attr_accessor :logger
  end

  self.logger = Logger.new STDERR

  def self.log message
    result = nil

    if block_given?
      ms = Benchmark.ms { result = yield }
      logger.info '%s (%.1fms)' % [ message, ms ]
    else
      result = logger.info message
    end

    result
  end

end
