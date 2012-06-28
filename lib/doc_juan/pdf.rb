require 'addressable/uri'

require_relative 'config'
require_relative 'pdf_options'
require_relative 'command_line_options'
require_relative 'generated_pdf'

module DocJuan
  class Pdf
    class InvalidUrlError < StandardError; end

    attr_reader :url, :filename, :options

    def self.executable
      @executable ||= 'wkhtmltopdf'
    end

    def self.executable= path
      @executable = path
    end

    def initialize url, filename, options = {}
      @url = url
      @filename = sanitize_filename filename

      @options = PdfOptions.prepare options
    end
    end

    def identifier
      @identifier ||= Digest::MD5.hexdigest [url, command_line_options.to_s].join(' ')
    end

    def command_line_options
      @command_line_options ||= DocJuan::CommandLineOptions.new options
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
        args << command_line_options.to_s
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

  end
end
