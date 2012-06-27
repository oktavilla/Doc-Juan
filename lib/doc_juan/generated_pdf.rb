module DocJuan
  class GeneratedPdf
    attr_accessor :filename

    def initialize name, result
      @name = name
      @result = result
    end

    def ok?
      !!@result
    end

    def path
      File.join DocJuan.config[:document_uri], @name
    end

    def mime_type
      'application/pdf'
    end
  end
end
