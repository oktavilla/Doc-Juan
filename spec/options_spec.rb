require_relative 'spec_helper'
require 'mocha'

require_relative '../lib/doc_juan/options'

describe DocJuan::Options do

  subject { DocJuan::Options.new [ :title, :height, :width, :size, :lowquality ] }

  it 'overwrites the defaults' do
    subject.stubs(:defaults).returns size: 'A4', width: '10mm'
    options = subject.prepare size: 'A4'

    options.must_equal size: 'A4', width: '10mm'
  end

  it 'makes the keys wkhtmltopdf friendly' do
    subject.stubs(:conversions).returns size: :page_size

    options = subject.prepare size: 'A4'

    options.must_equal page_size: 'A4'
  end

  it 'only allows keys in the whitelist' do
    subject.stubs(:whitelist).returns [:size]

    options = subject.prepare size: 'A4', width: '10mm'

    options.must_equal size: 'A4'
  end

  it 'strips bad characters from title' do
    options = subject.prepare title: ';rm /'
    options[:title].must_equal 'rm '
  end

  it 'raises BadValueError when finding evil values' do
     proc {
       pdf = subject.prepare size: ';rm /'
     }.must_raise DocJuan::Options::BadValueError
  end

  it 'typecasts boolean options' do
    options = subject.prepare lowquality: 'true'

    options[:lowquality].must_equal true
  end

  it 'does not care about key types' do
    options = subject.prepare 'size' => 'A4', :width => 10

    options.must_equal size: 'A4', width: 10
  end
end
