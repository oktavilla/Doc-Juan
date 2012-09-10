require_relative './spec_helper'
require 'mocha'
require_relative '../lib/doc_juan/generator_base'

require 'tmpdir'

describe 'GeneratorBase' do

  subject do
    class MaFile < DocJuan::GeneratorBase
      self.file_format = 'ma'
      self.mime_type = 'application/ma'
      self.executable = 'ma-stuffs'
      self.options = Hash[
        whitelist: [ :title, :size, :username, :password ],
        defaults: { size: 'A5' },
        conversions: { size: :page_size }
      ]
    end

    MaFile
  end

  let(:url) { 'http://example.com' }
  let(:filename) { 'document.ma' }
  let(:options) do
    { size: 'A5' }
  end

  describe 'setup' do
    it 'assigns format' do
      subject.file_format.must_equal 'ma'
    end

    it 'assigns mime_type' do
      subject.mime_type.must_equal 'application/ma'
    end

    it 'assigns executable' do
      subject.executable.must_equal 'ma-stuffs'
    end

    it 'assigns options' do
      subject.options.must_equal Hash[
        whitelist: [ :title, :size, :username, :password ],
        defaults: { size: 'A5' },
        conversions: { size: :page_size }
      ]
    end

  end

  it 'is initialized with url, filename and options' do
    file = subject.new url, filename, options

    file.url.must_equal 'http://example.com'
    file.filename.must_equal 'document.ma'
    file.options.must_equal Hash[ :page_size => 'A5' ]
  end


  it 'prepares the options' do
    options_parser = stub
    subject.stubs(:options_parser => options_parser)
    options_parser.expects(:prepare).with(options)

    subject.new(url, filename, options)
  end

  it 'has a unique identifier' do
    file = subject.new(url, filename, options)
    file.stubs(:options).returns size: 'A5', lowquality: true

    file.identifier.must_equal Digest::MD5.hexdigest 'http://example.com-lowqualitytruesizeA5'
  end

  it 'strips junk from the filename' do
    file = subject.new url, '/butters\\nacks../evil.sh', options
    file.filename.must_equal 'evil.ma'

    file = subject.new url, 'e v-il!.sh', options
    file.filename.must_equal 'e_v-il_.ma'
  end


  it 'knows if already generated' do
    file = subject.new(url, filename, options)
    File.expects(:exists?).with(file.path).returns true

    file.exists?.must_equal true
  end

  it 'has a generated pdf' do
    file = subject.new(url, filename, options)

    generated = file.generated true

    generated.path.must_equal "/documents/#{file.identifier}"
    generated.ok?.must_equal true
    generated.filename.must_equal filename
  end

  describe '#run_command' do

    it 'returns the status and output of the command' do
      file = subject.new(url, filename, options)
      status, output = file.run_command 'echo', 'monkey-wrench'

      status.must_equal true
      output.must_equal 'monkey-wrench'
    end

    it 'raises FailedRunningCommandError with the output in the message if the command fails' do
      file = subject.new(url, filename, options)
      proc {
        file.run_command 'ls', 'nonexistant'
      }.must_raise DocJuan::FailedRunningCommandError
    end

  end

  describe '#generate' do
    before :each do
      subject.any_instance.stubs(:directory).returns Dir.tmpdir
      subject.executable = 'wkhtmltopdf'
    end

    let(:file) { subject.new(url, filename, options) }

    it 'creates the pdf with wkhtmltopdf' do
      file.stubs(:exists?).returns false
      file.expects(:run_command).
        with('wkhtmltopdf', %Q{--page-size "A5" "#{url}" "#{Dir.tmpdir}/#{file.identifier}"}).
        returns [true, '']

      file.generate
    end

    describe 'http auth' do
      it 'creates the pdf with wkhtmltopdf' do
        file = subject.new(url, filename, options.merge({ :username => 'username', :password => 'password' }) )

        file.stubs(:exists?).returns false
        file.expects(:run_command).
          with('wkhtmltopdf', %Q{--page-size "A5" --username \"username\" --password \"password\" "#{url}" "#{Dir.tmpdir}/#{file.identifier}"}).
          returns [true, '']

        file.generate
      end

    end

    it 'notifies about errors and raises CouldNotGenerateFileError if failed' do
      file.expects(:run_command).raises DocJuan::FailedRunningCommandError, '=('
      DocJuan.expects(:log).with '=('

      proc {
        file.generate
      }.must_raise DocJuan::CouldNotGenerateFileError
    end

    it 'does not generate the pdf if it already exists' do
      file.stubs(:exists?).returns true
      file.expects(:run_command).never

      result = file.generate

      result.ok?.must_equal true
    end

    it 'returns a generated pdf with the path to the file' do
      file.stubs(:exists?).returns true
      file.stubs(:run_command).returns [true, '']
      result = file.generate

      result.path.must_equal "/documents/#{file.identifier}"
      result.ok?.must_equal true
      result.filename.must_equal filename
      result.mime_type.must_equal 'application/ma'
    end
  end
end
