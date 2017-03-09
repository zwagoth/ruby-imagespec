# encoding: ascii-8bit
class ImageSpec::Parser::JPEG

  CONTENT_TYPE = 'image/jpeg'

  def self.attributes(stream)
    width, height, remaining = dimensions(stream)
    {width: width, heigh: height, content_type: CONTENT_TYPE, dimensions: [width, height], file_size: size(stream), trailing_bytes: remaining}
  end

  def self.detected?(stream)
    stream.rewind
    stream.read(2) == "\xff\xd8"
  end

  def self.dimensions(stream)
    stream.rewind
    raise ImageSpec::Error, 'malformed JPEG' unless detected?(stream)

    class << stream
      def fullread(size)
        data = read(size)
        raise EOFError if data.nil? || data.length != size
        return data
      end

      def readbyte
        fullread(1)[0].ord
      end

      def readint
        fullread(2).unpack('n')[0]
      end

      def readframe
        fullread(readint - 2)
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

    width = height = -1

    marker = stream.readbyte
    while true
      if marker == 0xFF
        marker <<= 8
        marker |= stream.readbyte
      else
        marker = stream.readbyte
        next
      end

      case marker
        when 0x0, 0xFFFF # JUNK
          marker = 0xFF
        when 0xFF00 # padded 0xFF
          marker = stream.readbyte
        when 0xFFC0..0xFFC3, 0xFFC5..0xFFC7, 0xFFC9..0xFFCB, 0xFFCD..0xFFCF # SOF markers
          length, bits, hheight, wwidth, components = stream.readsof
          height = hheight
          width = wwidth
          raise ImageSpec::Error, 'malformed JPEG' unless length == 8 + components * 3
        when 0xFFD9 # EOI marker
          break
        when 0xFFC4, 0xFFCC # Huffman table, arithmetic coding condition
          stream.readframe
          marker = stream.readbyte
        when 0xFFC8 # Extension
          marker = stream.readbyte
        when 0xFFD0..0xFFD7, 0xFFD8, 0xFFF0..0xFFFE # Restart Markers, SOI, Extensions, Comments
          marker = stream.readbyte
        else
          stream.readframe
          marker = stream.readbyte
          # raise ImageSpec::Error, "malformed JPEG no marker: #{sprintf('%x', marker)}"
      end
    end

    current_pos = stream.pos
    stream.seek(0, IO::SEEK_END)
    remaining = stream.pos - current_pos
    return [width, height, remaining]
  end

  def self.size(stream)
    stream.size
  end

end
