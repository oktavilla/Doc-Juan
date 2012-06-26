require_relative '../spec_helper'
require 'mocha'

require_relative '../../lib/doc_juan/pdf.rb'

describe DocJuan::Pdf do
  let(:url) { 'http://example.com' }
  let(:filename) { 'document.pdf' }
  let(:options) do
    { page_size: 'A5' }
  end

  it 'ensures the url is valid' do
    proc {
      DocJuan::Pdf.new 'bad-url', filename, options
    }.must_raise DocJuan::Pdf::InvalidUrlError
  end

  it 'strips junk from the filename' do
    pdf = DocJuan::Pdf.new url, '/butters\\nacks../evil.sh', options
    pdf.filename.must_equal 'evil.pdf'

    pdf = DocJuan::Pdf.new url, 'e v-il!.sh', options
    pdf.filename.must_equal 'e_v-il_.pdf'
  end

  it 'sanitizes options' do
    DocJuan::Pdf.stub(:default_options, {}) do
      DocJuan::Pdf.stub(:available_options, [ :page_size ]) do
        pdf = DocJuan::Pdf.new(url, filename, { page_size: 'A4', color: 'white' })
        pdf.options.must_be :==, { page_size: 'A4'}
      end
    end
  end

  it 'appends default options' do
    DocJuan::Pdf.stub(:available_options, [ :page_size, :color ]) do
      DocJuan::Pdf.stub(:default_options, { page_size: 'A4', color: 'black' }) do
        pdf = DocJuan::Pdf.new(url, filename, { color: 'white' })
        pdf.options.must_be :==, { page_size: 'A4', color: 'white' }
      end
    end
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
    it 'passes the url, filename and options to wkhtmltopdf' do
      DocJuan::Pdf.stubs(:default_options).returns Hash.new
      pdf = DocJuan::Pdf.new url, filename, options
      pdf.expects(:system).with("wkhtmltopdf #{url} /documents/#{filename} --page-size A5")

      pdf.generate '/documents'
    end
  end
end
