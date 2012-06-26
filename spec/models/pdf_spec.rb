require_relative '../spec_helper'

require_relative '../../lib/doc_juan/pdf.rb'

describe DocJuan::Pdf do
  let(:url) { 'http://example.com' }
  let(:filename) { 'document.pdf' }
  let(:options) do
    { 'size' => 'A5' }
  end

  it 'is initalized with an url, a filename and options' do
    pdf = DocJuan::Pdf.new url, filename, options

    pdf.url.must_equal url
    pdf.filename.must_equal filename
    pdf.options.must_equal DocJuan::CommandLineOptions.new(options)
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
    DocJuan::Pdf.stub(:available_options, [ :size ]) do
      pdf = DocJuan::Pdf.new(url, filename, { size: 'A4', color: 'white' })
      pdf.options.must_be :==, { size: 'A4'}
    end
  end

  it 'appends default options' do
    DocJuan::Pdf.stub(:available_options, [ :size, :color ]) do
      DocJuan::Pdf.stub(:default_options, { size: 'A4', color: 'black' }) do
        pdf = DocJuan::Pdf.new(url, filename, { color: 'white' })
        pdf.options.must_be :==, { size: 'A4', color: 'white' }
      end
    end
  end

  describe '#generate' do
    it 'passes the url, filename and options to wkhtmltopdf'
  end
end
