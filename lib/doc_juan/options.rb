require 'active_support/all'

module DocJuan
  class Options

    class BadValueError < StandardError; end

    attr_accessor :whitelist, :defaults, :conversions

    def initialize whitelist = [], defaults = {}, conversions = {}
      @whitelist = whitelist
      @defaults = defaults
      @conversions = conversions
    end

    def prepare options = {}
      @options = (options || {}).symbolize_keys
      @options = sanitize @options
      @options = self.defaults.merge @options
      @options = typecast_booleans @options
      @options = convert_keys @options
      @options
    end

    def sanitize options
      evil_chars = /[^0-9a-zA-Z\-\_\.\s]/
      options.delete_if { |k, v| !self.whitelist.include?(k) }

      options[:title].gsub!(evil_chars, '') if options.key? :title

      raise BadValueError if options.values.detect { |v| v.to_s =~ evil_chars }

      options
    end

    def convert_keys options
      mapped = {}
      options.each do |key, value|
        if self.conversions.key? key
          mapped[self.conversions[key]] = value
        else
          mapped[key] = value
        end
      end

      mapped
    end

    def typecast_booleans options
      options.find_all { |k, v| ['true', 'false' ].include? v.to_s }.each do |k, v|
        options[k] = (v.to_s == 'true' ? true : false)
      end

      options
    end

  end
end
