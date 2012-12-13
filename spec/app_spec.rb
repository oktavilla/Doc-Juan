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
        DocJuan::Pdf.any_instance.stubs(:exists?).returns true
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

    it 'generates a pdf and returns a X-Accel-Redirect header pointing to it' do
      pdf = stub path: '/path/to/doc', filename: 'invoice.pdf', mime_type: 'application/pdf', ok?: true
      DocJuan::Pdf.any_instance.expects(:generate).returns pdf

      get "/render?url=#{url}&filename=#{filename}&format=pdf&key=21f1b9542c4e12c84d70c9026810a478615f7e37"

      last_response.headers['Content-Type'].must_equal 'application/pdf'
      last_response.headers['X-Accel-Redirect'].must_equal '/path/to/doc'
      last_response.headers['Content-Disposition'].must_equal "inline; filename=\"invoice.pdf\""
      last_response.headers['Cache-Control'].must_equal "public,max-age=2592000"
    end

    it 'generates a jpg and returns a X-Accel-Redirect header pointing to it' do
      jpg = stub path: '/path/to/doc', filename: 'invoice.jpg', mime_type: 'image/jpeg', ok?: true
      DocJuan::Jpg.any_instance.expects(:generate).returns jpg

      get "/render?url=#{url}&filename=#{filename}&key=13c61d7312bff6483b7c0f76e3b884b9aa2f47c3&format=jpg"

      last_response.headers['Content-Type'].must_equal 'image/jpeg'
      last_response.headers['X-Accel-Redirect'].must_equal '/path/to/doc'
      last_response.headers['Content-Disposition'].must_equal "inline; filename=\"invoice.jpg\""
      last_response.headers['Cache-Control'].must_equal "public,max-age=2592000"
    end

    it 'defaults to pdf as format' do
      pdf = stub path: '/path/to/doc', filename: 'invoice.pdf', mime_type: 'application/pdf', ok?: true
      DocJuan::Pdf.any_instance.expects(:generate).returns pdf

      get "/render?url=#{url}&filename=#{filename}&key=#{key}"
    end

    it 'fails with a 500 if the file could not be generated' do
      DocJuan::Pdf.any_instance.stubs(:exists?).returns false
      DocJuan::Pdf.any_instance.expects(:generate).raises DocJuan::CouldNotGenerateFileError

      get "/render", { url: url, filename: filename, key: key }

      last_response.status.must_equal 500
    end

  end

end
