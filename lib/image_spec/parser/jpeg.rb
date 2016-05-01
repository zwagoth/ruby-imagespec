# encoding: ascii-8bit
class ImageSpec::Parser::JPEG

  CONTENT_TYPE = 'image/jpeg'

  def self.attributes(stream)
    width, height = dimensions(stream)
    {:width => width, :height => height, :content_type => CONTENT_TYPE, :dimensions => [width, height], :file_size => size(stream)}
  end

  def self.detected?(stream)
    stream.rewind
    stream.read(2) == "\xff\xd8"
  end

  def self.dimensions(stream)
    stream.rewind
    raise ImageSpec::Error, 'malformed JPEG' unless detected?(stream)

    class << stream
      def readbyte
        read(1)[0].ord
      end

      def readint
        read(2).unpack('n')[0]
      end

      def readframe
        read(readint - 2)
      end

      def readsof
        [readint, readbyte, readint, readint, readbyte]
      end

      def next
        c = readbyte while c != 0xFF
        c = readbyte while c == 0xFF
        c
      end
    end

    while marker = stream.next
      case marker
      when 0xC0..0xC3, 0xC5..0xC7, 0xC9..0xCB, 0xCD..0xCF
        length, bits, height, width, components = stream.readsof
        raise ImageSpec::Error, 'malformed JPEG' unless length == 8 + components * 3
        return [width, height]
      when 0xD9, 0xDA
        break
      when 0xFE
        stream.readframe
      else
        stream.readframe
      end
    end
  end

  def self.size(stream)
    stream.size
  end

end
