# encoding: ascii-8bit
class ImageSpec::Parser::GIF
  CONTENT_TYPE = 'image/gif'

  def self.attributes(stream)
    width, height = dimensions(stream)
    duration, frames = gcinfo(stream)
    {:width => width, :height => height, :content_type => CONTENT_TYPE, :dimensions => [width, height], :file_size => size(stream), :duration => duration, :frames => frames}
  end

  def self.detected?(stream)
    stream.rewind
    stream.read(4) == 'GIF8'
  end

  def self.dimensions(stream)
    stream.seek(6)
    stream.read(4).unpack('SS')
  end

  def self.size(stream)
    stream.size
  end
  
  #Heavily referenced from http://stackoverflow.com/a/7506880
  #gcinfo because graphics control info
  def self.gcinfo(stream)
    begin
      #Skip header info because we know we are a gif
      stream.seek(10, IO::SEEK_SET)
      
      #Skip some data and jump over the colour table
      bFlags = stream.read(1)
      raise ImageSpec::Error, "Malformed GIF, EOF reached before end of file marker!" if bFlags.nil?
      gct_flags = bFlags.unpack("C")[0]
      
      stream.seek(2, IO::SEEK_CUR)
      
      if gct_flags & 0x80 == 0x80
          stream.seek(3 << ((gct_flags & 7) + 1), IO::SEEK_CUR)
      end
      
      frames = 0
      duration = 0.0
      while true do #For each block
        type = stream.read(1)
        raise ImageSpec::Error, "Malformed GIF, EOF reached before end of file marker!" if type.nil?
        #EOF block
        break if type == ";"
        
        #Extension block
        if type == "!"
          type = stream.read(1)
          if type == "\xF9" #Graphic Control Extension
            bLen = stream.read(1)
            raise ImageSpec::Error, "Malformed GIF, EOF reached before end of file marker!" if bLen.nil?
            gce_len = bLen.unpack("C")[0]
            if gce_len == 4 #We only know the 4 byte version
              bInfo = stream.read(4)
              raise ImageSpec::Error, "Malformed GIF, EOF reached before end of file marker!" if bInfo.nil?
              duration = duration + bInfo.unpack("CS<C")[1]
            else
              stream.seek(gce_len)
            end
          end
        #Image block
        elsif type == ","
          frames = frames + 1
          stream.seek(8, IO::SEEK_CUR)
          
          #Local colour table flags
          bFlags = stream.read(1)
          raise ImageSpec::Error, "Malformed GIF, EOF reached before end of file marker!" if bFlags.nil?
          lct_flags = bFlags.unpack("C")[0]
          
          if lct_flags & 0x80 == 0x80
            stream.seek(3 << ((lct_flags & 7) + 1), IO::SEEK_CUR)
          end
          
          stream.seek(1, IO::SEEK_CUR)
        else #Unknown block, lets scream about it
          raise ImageSpec::Error, "THE GIF IS RUINED, Call a programmer! Unknown block type: " + type.ord.to_s(16)
        end
        
        #Skip over the rest of the block's trailer
        while true do
          bLen = stream.read(1)
          raise ImageSpec::Error, "Malformed GIF, EOF reached before end of file marker!" if bLen.nil?
          l = bLen.unpack("C")[0]
          break if l == 0
          stream.seek(l, IO::SEEK_CUR)
        end
      end
      
      #Correction for GIFs made with software that can't even follow specs
      if duration == 0 and frames > 1
        #CASE: Gif contains multiple frames but zero delay
        duration = -1
      elsif frames == 1
        #CASE: Gif contains 1 frame but has a duration greater than zero
        duration = 0
      end
      
      #boop
      return [duration/100, frames]
    rescue EOFError
      raise ImageSpec::Error, "Malformed GIF, EOF reached before end of file marker!"
    end
  end

end
