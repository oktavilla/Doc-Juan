module DocJuan
  class GeneratedPdf
    attr_reader :path

    def initialize path, result
      @path = path
      @result = result
    end

    def ok?
      !!@result
    end
  end
end
