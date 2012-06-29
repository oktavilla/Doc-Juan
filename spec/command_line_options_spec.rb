require_relative 'spec_helper'

require_relative '../lib/doc_juan/command_line_options'

unless defined? DocJuan.config
  module DocJuan
    def self.config
      {}
    end
  end
end

describe DocJuan::CommandLineOptions do

  describe '#normalize options' do
    it 'converts the options keys' do
      clo = DocJuan::CommandLineOptions.new
      clo.normalize_options(paper_size: 'A4', path: '/').keys.must_equal ['--paper-size', '--path']
    end

    it 'converts true to nil' do
      clo = DocJuan::CommandLineOptions.new
      clo.normalize_options(ignore_whitespace: true).must_equal '--ignore-whitespace' => nil
    end

    it 'ignores false values' do
      clo = DocJuan::CommandLineOptions.new
      clo.normalize_options(ignore_whitespace: false, lowquality: true).must_equal '--lowquality' => nil

    end

  end

  it 'normalizes options and sorts them when used as a string' do
    clo = DocJuan::CommandLineOptions.new weight: 10, paper_size: 'A4', color: 'black', whitespace: true
    clo.to_s.must_equal '--color "black" --paper-size "A4" --weight "10" --whitespace'
  end

  it 'allows access to values by key' do
    clo = DocJuan::CommandLineOptions.new paper_size: 'A4'
    clo[:paper_size].must_equal 'A4'
  end

end
