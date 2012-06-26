require_relative 'spec_helper'

require_relative '../lib/doc_juan/command_line_options'

describe DocJuan::CommandLineOptions do

  it 'strips non allowed options if a whitelist is given' do
    clo = DocJuan::CommandLineOptions.new({ size: 'A4', path: '/' }, {}, [ :size ])
    clo.options.must_equal size: 'A4'
  end

  it 'has default options' do
    clo = DocJuan::CommandLineOptions.new({ size: 'A4'  }, { path: '/' })
    clo.options.must_equal size: 'A4', path: '/'
  end

  it 'overwrites the default options' do
    clo = DocJuan::CommandLineOptions.new({ size: 'A4', path: '/var'  }, { path: '/' })
    clo.options.must_equal size: 'A4', path: '/var'
  end

  describe 'normalized_options' do
    it 'converts the options keys' do
      clo = DocJuan::CommandLineOptions.new paper_size: 'A4', path: '/'

      clo.normalized_options.keys.must_equal ['--paper-size', '--path']
    end

    it 'converts boolean values to nil' do
      clo = DocJuan::CommandLineOptions.new ignore_whitespace: true
      clo.normalized_options.must_equal '--ignore-whitespace' => nil
    end
  end

  it 'uses the normalized options when used as a string' do
    clo = DocJuan::CommandLineOptions.new paper_size: 'A4', color: 'black', weight: 10
    clo.to_s.must_equal '--paper-size A4 --color black --weight 10'
  end

end
