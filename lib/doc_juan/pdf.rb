require 'addressable/uri'
require_relative 'config'
require_relative 'command_line_options'
require_relative 'generated_pdf'

module DocJuan
  class Pdf
    class InvalidUrlError < StandardError; end
    class BadOptionValueError < StandardError; end

    attr_reader :url, :filename, :options

    def self.available_options
      [
        :title,
        :lowquality,
        :orientation,
        :height, :width, :size,
        :print_stylesheet
      ]
    end

    def self.default_options
      {
        size:          'A4',
        margin_top:    '0mm',
        margin_right:  '0mm',
        margin_bottom: '0mm',
        margin_left:   '0mm'
      }
    end

    def self.options_to_arguments
      {
        size: :page_size,
        width: :page_width,
        height: :page_height,
        print_stylesheet: :print_media_type
      }
    end

    def self.executable
      @executable ||= 'wkhtmltopdf'
    end

    def self.executable= path
      @executable = path
    end

    def initialize url, filename, options = {}
      @url = url
      @filename = sanitize_filename filename

      @options = DocJuan::CommandLineOptions.new prepare_options(options)
    end

    def identifier
      @identifier ||= Digest::MD5.hexdigest [url, options.to_s].join(' ')
    end

    def path
      File.join DocJuan.config[:document_path], identifier
    end

    def exists?
      File.exists? path
    end

    def generated result = exists?
      pdf = GeneratedPdf.new identifier, result
      pdf.filename = self.filename
      pdf
    end

    def generate
      unless exists?
        path = File.join directory, identifier
        args = [self.class.executable]
        args << %Q{"#{url}"}
        args << %Q{"#{path}"}
        args << options.to_s
        args << '--quiet'

        run_command args.join(' ')
      end

      generated
    end

    def run_command command
      system command
    end

    def directory
      DocJuan.config[:document_path]
    end

    private

    def sanitize_filename filename
      ext = File.extname filename.to_s
      filename = File.basename filename.to_s.strip, ext
      sanitized_filename = filename.gsub /[^A-Za-z0-9\.\-]/, '_'

      "#{sanitized_filename}.pdf"
    end

    def prepare_options options
      options = sanitize_options(options || {})
      options = self.class.default_options.merge options
      options = map_to_arguments(options)

      options
    end

    def sanitize_options options
      bad_chars_regex = /[^0-9a-zA-Z\-\_\.\s]/

      options.delete_if { |k, v| !self.class.available_options.include?(k) }

      options[:print_stylesheet] = true if options.key? :print_stylesheet
      options[:lowquality] = true if options.key? :lowquality

      options[:title].gsub!(bad_chars_regex, '') if options.key? :title

      if options.values.detect { |value| value.to_s =~ bad_chars_regex }
        raise BadOptionValueError
      end

      options
    end

    def map_to_arguments options
      mapped_options = {}
      options.each do |key, value|
        if self.class.options_to_arguments.has_key?(key)
          mapped_options[self.class.options_to_arguments[key]] = value
        else
          mapped_options[key] = value
        end
      end

      mapped_options
    end

  end
end
