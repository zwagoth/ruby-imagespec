# encoding: ascii-8bit
class ImageSpec::Parser::BMP
  CONTENT_TYPE = 'image/bmp'

  def self.attributes(stream)
    width, height = dimensions(stream)
    {:width => width, :height => height, :content_type => CONTENT_TYPE, :dimensions => [width, height], :file_size => size(stream)}
  end

  def self.detected?(stream)
    stream.rewind
    stream.read(2) == 'BM'
  end

  def self.dimensions(stream)
    stream.seek(18)
    stream.read(8).unpack('LL')
  end

  def self.size(stream)
    stream.size
  end

end
