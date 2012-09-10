require_relative './jpg'
require_relative './pdf'
module DocJuan
  class UnKnownFormat < StandardError; end
  def self.renderer format
    if format == "jpg"
     DocJuan::Jpg
    elsif format == "pdf" || format.blank?
      DocJuan::Pdf
    else
      raise UnKnownFormat
    end
  end
end
