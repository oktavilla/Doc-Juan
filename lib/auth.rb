require 'openssl'

class Auth

  attr_reader :params

  def initialize params = {}
    @params = params
  end

  def digest
    OpenSSL::HMAC.hexdigest(sha1, secret, message)
  end

  def message
    params.sort.map {|k,v| "#{k}:#{v}" if v && !v.empty? }.join('-')
  end

  def secret
    ENV['DOC_JUAN_SECRET']
  end

  def self.valid_request? request
    params = request.params
    key = params.delete('key')
    key == Auth.new(params).digest
  end

  private

  def sha1
    OpenSSL::Digest::Digest.new('sha1')
  end

end
