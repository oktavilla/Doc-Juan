require 'addressable/uri'
require_relative './command_line_options'

module DocJuan
  class Pdf
    class InvalidUrlError < StandardError; end
    attr_accessor :url, :filename, :options

    def self.available_options
      {}
    end

    def self.default_options
      {}
    end

    def initialize url, filename, options = {}
      self.url = url
      self.filename = filename
      self.options = options
    end

    def url= url
      validate_url url
      @url = url
    end

    def filename= filename
      @filename = sanitize_filename filename
    end

    def options= options
      sanitized_options = sanitize_options options
      sanitized_options = self.class.default_options.merge sanitized_options
      @options = DocJuan::CommandLineOptions.new sanitized_options
    end

    private

    def validate_url url
      begin
        parsed_url = Addressable::URI.parse url
        raise InvalidUrlError unless %w{http https}.include? parsed_url.scheme
      rescue Addressable::URI::InvalidURIError
        raise InvalidUrlError
      end
    end

    def sanitize_filename filename
      ext = File.extname filename.to_s
      filename = File.basename filename.to_s.strip, ext
      sanitized_filename = filename.gsub /[^A-Za-z0-9\.\-]/, '_'

      "#{sanitized_filename}.pdf"
    end

    def sanitize_options options
      options.delete_if { |k, v| !self.class.available_options.include?(k) }
    end
  end
end
