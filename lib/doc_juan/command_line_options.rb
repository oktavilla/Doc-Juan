module DocJuan
  class CommandLineOptions
    include Comparable

    attr_accessor :options

    def initialize options, default_options = {}, whitelist = []
      if whitelist.any?
        options = options.delete_if { |k, v| !whitelist.include?(k) }
      end
      self.options = default_options.merge options
    end

    def == other
      if other.is_a? self.class
        self.options == other.options
      else
        self.options == other
      end
    end

    def normalized_options
      normalized_options = {}
      options.each do |k, v|
        key = "--#{k}".to_s.gsub(/[^a-z0-9\-]/, '-')
        normalized_options[key] = v.is_a?(TrueClass) ? nil : v.to_s
      end

      normalized_options
    end

    def to_s
      normalized_options.to_a.flatten.compact.join(' ')
    end
  end
end
