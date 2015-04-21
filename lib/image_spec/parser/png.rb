# encoding: ascii-8bit
class ImageSpec::Parser::PNG
  CONTENT_TYPE = 'image/png'

  def self.attributes(stream)
    width, height = dimensions(stream)
    {:width => width, :height => height, :content_type => CONTENT_TYPE, :dimensions => [width, height], :file_size => size(stream)}
  end

  def self.detected?(stream)
    stream.rewind
    stream.read(4) == "\x89PNG"
  end

  def self.dimensions(stream)
    stream.seek(0x10)
    stream.read(8).unpack('NN')
  end

  def self.size(stream)
    stream.size
  end

end
