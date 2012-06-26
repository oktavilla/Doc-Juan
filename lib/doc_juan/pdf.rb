require 'addressable/uri'
require_relative './command_line_options'

module DocJuan
  class Pdf
    class InvalidUrlError < StandardError; end

    attr_reader :url, :filename, :options

    def self.available_options
      [
        :title,
        :regenerate,
        :name,
        :cover, :debug_javascript, :default_header,
        :disable_external_links, :disable_internal_links,
        :disable_javascript, :disable_pdf_compression,
        :disable_smart_shrinking, :no_background,
        :forms, :grayscale, :lowquality,
        :zoom, :minimum_font_size,
        :orientation,
        :margin_bottom, :margin_left, :margin_right, :margin_top,
        :page_height, :page_width, :page_size,
        :page_offset,
        :print_media_type, :redirect_delay,
        :replace,
        :stop_slow_scripts,
        :username, :password,
        :outline, :outline_depth,
        :user_style_sheet, :stylesheets
      ]
    end

    def self.default_options
      {
        page_size:     'A4',
        margin_top:    '0mm',
        margin_right:  '0mm',
        margin_bottom: '0mm',
        margin_left:   '0mm'
      }
    end

    def self.executable
      @executable ||= 'wkhtmltopdf'
    end

    def self.executable= path
      @executable = path
    end

    def initialize url, filename, options = {}
      self.url = url
      self.filename = filename

      options = sanitize_options options
      options = self.class.default_options.merge options
      @options = DocJuan::CommandLineOptions.new options
    end

    def url= url
      validate_url url
      @url = url
    end

    def filename= filename
      @filename = sanitize_filename filename
    end

    def generate path
      path = File.join path, filename

      args = [self.class.executable]
      args << url
      args << path
      args << options.to_s

      system args.join(' ')
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
