require_relative 'generator_base'

module DocJuan
  class Jpg < GeneratorBase
    self.file_format = 'jpg'
    self.mime_type = 'image/jpeg'
    self.executable = 'wkhtmltoimage'
    self.options = {
      whitelist:[
        :height, :width, :quality, :encoding,
        :username, :password
      ],
      defaults: {
        quality: 80,
        format: 'jpg',
        encoding: 'UTF-8',
      },
      conversions: {}
    }
  end
end
