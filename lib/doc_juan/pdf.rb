require 'addressable/uri'

module DocJuan
  class Pdf
    class InvalidUrlError < StandardError; end
    attr_accessor :url, :filename, :options

    def initialize url, filename, options
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
  end
end
