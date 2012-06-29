require_relative 'spec_helper'
require 'mocha'

require_relative '../lib/doc_juan/pdf_options'

describe DocJuan::PdfOptions do
  before :each do
    DocJuan::PdfOptions.stubs(:defaults).returns Hash.new
    DocJuan::PdfOptions.stubs(:conversions).returns Hash.new
  end

  it 'overwrites the defaults' do
    DocJuan::PdfOptions.stubs(:defaults).returns size: 'A4', width: '10mm'
    options = DocJuan::PdfOptions.prepare size: 'A4'

    options.must_equal size: 'A4', width: '10mm'
  end

  it 'makes the keys wkhtmltopdf friendly' do
    DocJuan::PdfOptions.stubs(:conversions).returns size: :page_size

    options = DocJuan::PdfOptions.prepare size: 'A4'

    options.must_equal page_size: 'A4'
  end

  it 'only allows keys in the whitelist' do
    DocJuan::PdfOptions.stubs(:whitelist).returns [:size]

    options = DocJuan::PdfOptions.prepare size: 'A4', width: '10mm'

    options.must_equal size: 'A4'
  end

  it 'strips bad characters from title' do
    options = DocJuan::PdfOptions.prepare title: ';rm /'
    options[:title].must_equal 'rm '
  end

  it 'raises BadValueError when finding evil values' do
     proc {
       pdf = DocJuan::PdfOptions.prepare size: ';rm /'
     }.must_raise DocJuan::PdfOptions::BadValueError
  end

  it 'typecasts boolean options' do
    options = DocJuan::PdfOptions.prepare lowquality: 'true'

    options[:lowquality].must_equal true
  end

  it 'does not care about key types' do
    options = DocJuan::PdfOptions.prepare 'size' => 'A4', :width => 10

    options.must_equal size: 'A4', width: 10
  end
end
