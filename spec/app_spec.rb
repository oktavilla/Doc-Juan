require_relative './spec_helper'
require 'rack/test'
require 'mocha'

require_relative '../lib/doc_juan'

describe DocJuan::App do
  include Rack::Test::Methods

  def app
    DocJuan::App
  end

  describe '/' do

    it 'renders an empty 200 page' do
      get '/'
      last_response.ok?.must_equal true
      last_response.body.must_be :empty?
    end

  end

  describe '/render' do

    before do
      DocJuan::Auth.any_instance.stubs(:secret).returns 'zecret'
    end

    let(:key) { '6b9318c65de6f0e382b9d3f1b00124e3550032d3' }
    let(:url) { 'http://example.com' }
    let(:filename) { 'invoice' }

    describe 'authorization' do
      before :each do
        DocJuan::Pdf.any_instance.stubs(:run_command).returns true
      end

      it 'returns a 401 (Unauthorized) when key is invalid' do
        get "/render?url=#{url}filename=#{filename}&key=wrong"
        last_response.status.must_equal 401
      end

      it 'returns a 200 (OK) when key is valid' do
        get "/render?url=#{url}&filename=#{filename}&key=#{key}"
        last_response.status.must_equal 200
      end

    end

    it 'returns a X-Accel-Redirect header pointing to the generated pdf' do
      DocJuan::Pdf.any_instance.stubs(:run_command).returns true
      DocJuan::Pdf.any_instance.stubs(:exists?).returns true
      DocJuan::GeneratedPdf.any_instance.stubs(:path).returns '/path/to/doc'

      get "/render?url=#{url}&filename=#{filename}&key=#{key}"

      last_response.headers['X-Accel-Redirect'].must_equal '/path/to/doc'
      last_response.headers['Content-Disposition'].must_equal "attachment; filename=\"#{filename}.pdf\""
    end

  end

end
