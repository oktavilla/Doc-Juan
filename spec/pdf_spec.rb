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

    pdf.identifier.must_equal '9d9f70611b5217ddbea862a22c2edfc3'
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
    File.stubs(:exists?).returns true

    generated = pdf.generated

    generated.path.must_equal "/documents/#{pdf.identifier}"
    generated.ok?.must_equal true
    generated.filename.must_equal filename
    generated.mime_type.must_equal 'application/pdf'
  end

  it 'maps input options to wkhtmltopdf arguments' do
    options = { height: 1, width: 2, size: 'A3', print_stylesheet: 'true', lowquality: 1 }
    pdf = DocJuan::Pdf.new(url, filename, options)

    pdf.options[:page_height].must_equal 1
    pdf.options[:page_width].must_equal 2
    pdf.options[:page_size].must_equal 'A3'
    pdf.options[:print_media_type].must_equal true
    pdf.options[:lowquality].must_equal true
  end

  it 'sanitizes options' do
    DocJuan::Pdf.stubs(:default_options).returns Hash.new
    DocJuan::Pdf.stubs(:available_options).returns [ :size ]

    pdf = DocJuan::Pdf.new(url, filename, { size: 'A4', color: 'white' })
    pdf.options.must_be :==, { page_size: 'A4'}
  end

  it 'raises BadOptionValueError on evil option values' do
     proc do
       pdf = DocJuan::Pdf.new(url, filename, { size: ';rm /' })
     end.must_raise DocJuan::Pdf::BadOptionValueError
  end

  it 'strips bad characters from options title' do
    pdf = DocJuan::Pdf.new(url, filename, { title: ';rm /' })
    pdf.options[:title].must_equal 'rm '
  end

  it 'appends default options' do
    DocJuan::Pdf.stubs(:available_options).returns [ :size, :color ]
    DocJuan::Pdf.stubs(:default_options).returns(size: 'A4', color: 'black')

    pdf = DocJuan::Pdf.new(url, filename, { color: 'white' })
    pdf.options.must_be :==, { page_size: 'A4', color: 'white' }
  end

  it 'has a default executable' do
    DocJuan::Pdf.executable.must_equal 'wkhtmltopdf'
  end

  it 'sets a new executable path' do
    DocJuan::Pdf.executable = '/usr/local/bin/wkhtmltopdf'
    DocJuan::Pdf.executable.must_equal'/usr/local/bin/wkhtmltopdf'

    DocJuan::Pdf.executable = nil
  end

  describe '#generate' do
    before :each do
      DocJuan::Pdf.stubs(:default_options).returns Hash.new
      DocJuan::Pdf.any_instance.stubs(:directory).returns '/documents'
    end

    subject { DocJuan::Pdf.new(url, filename, options) }

    it 'passes the url, filename and options to wkhtmltopdf' do
      subject.expects(:system).with("wkhtmltopdf \"#{url}\" \"/documents/#{subject.identifier}\" --page-size \"A5\"")

      subject.generate
    end

    it 'returns a generated pdf with the path to the file' do
      File.stubs(:exists?).returns true
      subject.stubs(:run_command).returns true
      result = subject.generate

      result.path.must_equal "/documents/#{subject.identifier}"
      result.ok?.must_equal true
      result.filename.must_equal filename
      result.mime_type.must_equal 'application/pdf'
    end
  end
end
