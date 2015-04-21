require 'open-uri'

class ImageSpec
  Error = Class.new(StandardError)

  def initialize(file)
    @attributes = Parser.parse(stream_for(file))

    @attributes.each do |key, value|
      instance_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{key}
          @attributes[:#{key}]
        end
      RUBY
    end
  end

  private

  def stream_for(file)
    if file.respond_to?(:read)
      file
    elsif file.is_a?(String)
      open(file, 'rb')
    else
      raise "Unable to get stream for #{file.inspect}"
    end
  end

end

%w|parser|.each do |name|
  require "image_spec/#{name}"
end
