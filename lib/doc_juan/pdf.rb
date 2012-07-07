require 'addressable/uri'

require_relative 'logger'
require_relative 'config'
require_relative 'pdf_options'
require_relative 'command_line_options'
require_relative 'generated_pdf'

module DocJuan
  class Pdf
    class InvalidUrlError < StandardError; end
    class FailedRunningCommandError < StandardError; end
    class CouldNotGeneratePdfError < StandardError; end

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

      self.options = options
    end

    def options= options
      @options = PdfOptions.prepare options
    end

    def identifier
      @identifier ||= Digest::MD5.hexdigest [url, command_line_options.to_argument_string].join(' ')
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
        args = []
        args << %Q{"#{url}"}
        args << %Q{"#{path}"}
        args << command_line_options.to_argument_string
        args << '--quiet'

        begin
          run_command self.class.executable, args.join(' ')
        rescue FailedRunningCommandError => e
          DocJuan.log e.message
          raise CouldNotGeneratePdfError.new e.message
        end
      end

      generated
    end

    def run_command command, command_options
      output = ''

      pid, status = DocJuan.log "Processing: #{url}" do
        rd, wr = IO.pipe

        pid = Process.spawn [command, command_options].join(' '), [:out, :err] => wr
        wr.close

        output << rd.read.to_s.strip
        rd.close

        Process.waitpid2 pid
      end

      unless status.success?
        raise FailedRunningCommandError.new "Failed running #{command}: #{output}"
      end

      [status.success?, output]
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
