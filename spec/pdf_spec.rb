require_relative 'spec_helper'
require 'mocha'

require_relative '../lib/doc_juan/pdf.rb'

describe DocJuan::Pdf do
  let(:url) { 'http://example.com' }
  let(:filename) { 'document.pdf' }
  let(:options) do
    { size: 'A5' }
  end

  it 'has a unique identifier' do
    pdf = DocJuan::Pdf.new(url, filename, options)

    pdf.identifier.must_equal Digest::MD5.hexdigest 'http://example.com-lowqualitytruesizeA5'
  end

  it 'strips junk from the filename' do
    pdf = DocJuan::Pdf.new url, '/butters\\nacks../evil.sh', options
    pdf.filename.must_equal 'evil.pdf'

    pdf = DocJuan::Pdf.new url, 'e v-il!.sh', options
    pdf.filename.must_equal 'e_v-il_.pdf'
  end

  it 'knows if already generated' do
    pdf = DocJuan::Pdf.new(url, filename, options)
    File.expects(:exists?).with(pdf.path).returns true

    pdf.exists?.must_equal true
  end

  it 'has a generated pdf' do
    pdf = DocJuan::Pdf.new(url, filename, options)

    generated = pdf.generated true

    generated.path.must_equal "/documents/#{pdf.identifier}"
    generated.ok?.must_equal true
    generated.filename.must_equal filename
    generated.mime_type.must_equal 'application/pdf'
  end

  it 'has a default executable' do
    DocJuan::Pdf.executable.must_equal 'wkhtmltopdf'
  end

  describe '#run_command' do

    it 'returns the status and output of the command' do
      pdf = DocJuan::Pdf.new(url, filename, options)
      status, output = pdf.run_command 'echo', 'monkey-wrench'

      status.must_equal true
      output.must_equal 'monkey-wrench'
    end

    it 'raises FailedRunningCommandError with the output in the message if the command fails' do
      pdf = DocJuan::Pdf.new(url, filename, options)
      proc {
        pdf.run_command 'ls', 'nonexistant'
      }.must_raise DocJuan::FailedRunningCommandError
    end

  end


  describe '#generate' do
    before :each do
      DocJuan::Pdf.options[:defaults] = Hash.new
      DocJuan::Pdf.any_instance.stubs(:directory).returns '/documents'
    end

    subject { DocJuan::Pdf.new(url, filename, options) }

    it 'creates the pdf with wkhtmltopdf' do
      subject.stubs(:exists?).returns false
      subject.expects(:run_command).
        with('wkhtmltopdf', %Q{"#{url}" "/documents/#{subject.identifier}" --page-size "A5" --quiet}).
        returns [true, '']

      subject.generate
    end

    describe 'http auth' do

      subject { DocJuan::Pdf.new(url, filename, options.merge({ :username => 'username', :password => 'password' }) ) }

      it 'creates the pdf with wkhtmltopdf' do
        subject.stubs(:exists?).returns false
        subject.expects(:run_command).
          with('wkhtmltopdf', %Q{"#{url}" "/documents/#{subject.identifier}" --page-size "A5" --password \"password\" --username \"username\" --quiet}).
          returns [true, '']

        subject.generate
      end

    end

    it 'notifies about errors and raises CouldNotGenerateFileError if failed' do
      subject.expects(:run_command).raises DocJuan::FailedRunningCommandError, '=('
      DocJuan.expects(:log).with '=('

      proc {
        subject.generate
      }.must_raise DocJuan::CouldNotGenerateFileError
    end

    it 'does not generate the pdf if it already exists' do
      subject.stubs(:exists?).returns true
      subject.expects(:run_command).never

      result = subject.generate

      result.ok?.must_equal true
    end

    it 'returns a generated pdf with the path to the file' do
      subject.stubs(:exists?).returns true
      subject.stubs(:run_command).returns [true, '']
      result = subject.generate

      result.path.must_equal "/documents/#{subject.identifier}"
      result.ok?.must_equal true
      result.filename.must_equal filename
      result.mime_type.must_equal 'application/pdf'
    end
  end

end
