require_relative 'logger'
require_relative 'config'
require_relative 'options'
require_relative 'command_line_options'
require_relative 'generated_file'

module DocJuan

  class InvalidUrlError < StandardError; end
  class FailedRunningCommandError < StandardError; end
  class CouldNotGenerateFileError < StandardError; end

  class GeneratorBase

    class << self
      attr_accessor :file_format
      attr_accessor :mime_type
      attr_accessor :executable
      attr_accessor :options

      def options_parser
        Options.new(
          self.options[:whitelist],
          self.options[:defaults],
          self.options[:conversions]
        )
      end

    end

    attr_reader :url, :filename, :options

    def initialize url, filename, options = {}
      @url = url
      @filename = sanitize_filename filename

      self.options = options
    end

    def options= options
      @options = options_parser.prepare options
    end

    def options_parser
      @options_parser ||= self.class.options_parser
    end

    def identifier
      @identifier ||= Digest::MD5.hexdigest [url, options.sort.join].join('-')
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
      file = GeneratedFile.new identifier, result
      file.filename = self.filename
      file.mime_type = self.class.mime_type
      file
    end

    def generate
      unless exists?
        path = File.join directory, identifier
        args = []
        args << command_line_options.to_argument_string
        args << %Q{"#{url}"}
        args << %Q{"#{path}"}

        begin
          run_command self.class.executable, args.join(' ')
        rescue FailedRunningCommandError => e
          DocJuan.log e.message
          raise CouldNotGenerateFileError.new e.message
        end
      end

      generated
    end

    def run_command command, command_options
      output = ''

      DocJuan.log "#{command} #{command_options}"

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

      "#{sanitized_filename}.#{self.class.file_format}"
    end
  end
end
