# encoding: ascii-8bit
class ImageSpec::Parser::PNG
  CONTENT_TYPE = 'image/png'

  def self.attributes(stream)
    width, height, remaining, comments, unknown = dimensions(stream)
    {width: width, height: height, content_type: CONTENT_TYPE, dimensions: [width, height], file_size: size(stream), trailing_bytes: remaining, comment_bytes: comments, unknown_bytes: unknown}
  end

  def self.detected?(stream)
    stream.rewind
    stream.read(4) == "\x89PNG"
  end

  def self.fullread(stream, size)
    data = stream.read(size)
    raise EOFError if data.nil? || data.length != size
    return data
  end

  def self.readchunk(stream)
    length, magic = fullread(stream, 8).unpack('NA4')
    [length, magic]
  end

  def self.dimensions(stream)
    known_chunks = ['IHDR', 'IDAT', 'PLTE', 'IEND', 'tRNS', 'gAMA', 'cHRM', 'iCCP', 'sBIT', 'sRGB', 'tIME', 'hIST', 'pHYs', 'sPLT', 'bKGD', 'acTL', 'fcTL', 'fdAT', 'tEXt', 'iTXt', 'zTXt'].to_set
    allow_multipkme = ['sPLT', 'IDAT', 'fcTL', 'fdAT'].to_set
    seen_chunks = {}
    stream.seek(8) # skip PNG header

    width = height = nil
    comments = 0
    unknown = 0

    begin
      while chunk = readchunk(stream)
        case chunk[1]
          when 'IEND'
            stream.seek(4, IO::SEEK_CUR) # skip CRC
            break
          when 'IHDR'
            width, height = fullread(stream, 8).unpack('NN')
            stream.seek(-8, IO::SEEK_CUR)
          when 'iTXt', 'zTXt', 'tEXt'
            comments += chunk[0]
        end
        if !known_chunks.include?(chunk[1])
          unknown += chunk[0]
        end

        stream.seek(chunk[0] + 4, IO::SEEK_CUR) # skip CRC
      end
    rescue EOFError
      raise ImageSpec::Error, 'Unexpected EOF in PNG file. Most likely truncated or malformed.'
    end
    current_pos = stream.pos
    stream.seek(0, IO::SEEK_END)
    remaining = stream.pos - current_pos
    return [width, height, remaining, comments, unknown]
  end

  def self.size(stream)
    stream.size
  end

end
