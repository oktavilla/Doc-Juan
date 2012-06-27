module DocJuan
  def self.config
    @config ||= {
      secret: (ENV['DOC_JUAN_SECRET'] || ''),
      document_path: (ENV['DOC_JUAN_DOCUMENT_PATH'] || File.expand_path('../../../tmp/documents', __FILE__)),
      document_uri: (ENV['DOC_JUAN_DOCUMENT_URI'] || '/documents')
    }
  end
end
