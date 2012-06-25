require 'openssl'

class Auth

  attr_reader :params

  def initialize params = {}
    @params = params
  end

  def prepared_params
    Hash[flatten(params).sort]
  end

  def digest
    OpenSSL::HMAC.hexdigest(sha1, secret, message)
  end

  def message
    prepared_params.map {|k,v| "#{k}:#{v}" if v && !v.empty? }.join('-')
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

  def flatten input_hash
    input_hash.inject({}) do |res, (k,v)|
      if v.is_a?(Hash)
        v.each { |_k, _v| res["#{k}_#{_k}"] = _v }
      else
        res[k] = v
      end

      res
    end
  end

  def sha1
    OpenSSL::Digest::Digest.new('sha1')
  end

end
