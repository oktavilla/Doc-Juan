require 'active_support/all'

module DocJuan
  module PdfOptions

    class BadValueError < StandardError; end

    class << self
      attr_accessor :whitelist, :defaults, :conversions
    end

    self.whitelist = [
      :title,
      :lowquality,
      :orientation,
      :height, :width, :size,
      :print_stylesheet,
      :encoding,
      :username, :password
    ]

    self.defaults = {
      size:          'A4',
      margin_top:    '0mm',
      margin_right:  '0mm',
      margin_bottom: '0mm',
      margin_left:   '0mm',
      encoding:      'UTF-8'
    }

    self.conversions = {
      size: :page_size,
      width: :page_width,
      height: :page_height,
      print_stylesheet: :print_media_type
    }

    def self.prepare options
      options = (options || {}).symbolize_keys
      options = self.sanitize options
      options = self.defaults.merge options
      self.typecast_booleans options
      options = self.convert_keys options

      options
    end

    def self.sanitize options
      evil_chars = /[^0-9a-zA-Z\-\_\.\s]/
      options.delete_if { |k, v| !self.whitelist.include?(k) }

      options[:title].gsub!(evil_chars, '') if options.key? :title

      raise BadValueError if options.values.detect { |v| v.to_s =~ evil_chars }

      options
    end

    def self.convert_keys options
      mapped = {}
      options.each do |key, value|
        if self.conversions.key? key
          mapped[self.conversions[key]] = value
        else
          mapped[key] = value
        end
      end

      mapped
    end

    def self.typecast_booleans options
      options.find_all { |k, v| ['true', 'false' ].include? v.to_s }.each do |k, v|
        options[k] = (v.to_s == 'true' ? true : false)
      end
    end

  end
end
