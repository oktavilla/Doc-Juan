module DocJuan
  class GeneratedFile
    attr_accessor :filename
    attr_accessor :mime_type

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

  end
end
