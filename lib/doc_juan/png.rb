require_relative 'generator_base'

module DocJuan
  class Png < GeneratorBase
    self.file_format = 'png'
    self.mime_type = 'image/png'
    self.executable = 'wkhtmltoimage'
    self.options = {
      whitelist:[
        :height, :width, :quality, :encoding,
        :username, :password
      ],
      defaults: {
        quality: 90,
        format: 'png',
        encoding: 'UTF-8',
      },
      conversions: {}
    }
  end
end
