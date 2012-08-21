require_relative 'generator_base'

module DocJuan
  class Pdf < GeneratorBase
    self.file_format = 'pdf'
    self.mime_type = 'application/pdf'
    self.executable = 'wkhtmltopdf'
    self.options = {
      whitelist:[
        :title,
        :lowquality, :orientation, :height, :width, :size,
        :print_stylesheet, :encoding,
        :username, :password
      ],
      defaults: {
        size:          'A4',
        margin_top:    '0mm',
        margin_right:  '0mm',
        margin_bottom: '0mm',
        margin_left:   '0mm',
        encoding:      'UTF-8'
      },
      conversions: {
        size: :page_size,
        width: :page_width,
        height: :page_height,
        print_stylesheet: :print_media_type
      }
    }
  end
end
