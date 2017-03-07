module ImageSpec::Parser

  def self.formats
    @@formats ||= constants.collect { |format| const_get(format) }
  end

  def self.parse(stream)
    formats.each do |format|
      return format.attributes(stream) if format.detected?(stream)
    end
    raise ImageSpec::Error, "#{stream.inspect} is not a supported image format. Sorry bub :("
  end

end

%w|gif jpeg png swf|.each do |name|
  require "image_spec/parser/#{name}"
end
