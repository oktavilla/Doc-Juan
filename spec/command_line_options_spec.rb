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

    it 'converts boolean values to nil' do
      clo = DocJuan::CommandLineOptions.new
      clo.normalize_options(ignore_whitespace: true).must_equal '--ignore-whitespace' => nil
    end
  end

  it 'normalizes options when used as a string' do
    clo = DocJuan::CommandLineOptions.new paper_size: 'A4', color: 'black', weight: 10
    clo.to_s.must_equal '--paper-size A4 --color black --weight 10'
  end

end
