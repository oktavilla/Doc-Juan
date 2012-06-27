module DocJuan
  class CommandLineOptions
    include Comparable

    attr_reader :options

    def initialize options = {}
      @options = options
    end

    def == other
      if other.is_a? self.class
        options == other.options
      else
        options == other
      end
    end

    def normalize_options options
      normalized_options = {}
      options.each do |k, v|
        key = "--#{k}".to_s.gsub(/[^a-z0-9\-]/, '-')
        normalized_options[key] = v.is_a?(TrueClass) ? nil : %Q{"#{v.to_s}"}
      end

      normalized_options
    end

    def to_s
      normalized_options = normalize_options(options).to_a
      normalized_options = normalized_options.sort_by { |o| o[0] }
      normalized_options.flatten.compact.join(' ')
    end

    def [](key)
      options[key]
    end
  end
end
