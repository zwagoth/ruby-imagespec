$: << File.join(File.dirname(__FILE__),'..', 'lib')

require 'test/unit'
require 'image_spec'

class ImageSpecTest < Test::Unit::TestCase
  # Replace this with your real tests.

  def fixture(name)
    File.open File.expand_path("../fixtures/#{name}", __FILE__), 'rb'
  end

  def assert_spec(values, spec)
    assert_equal values, [spec.width, spec.height, spec.content_type]
  end

  def test_identifying_jpeg
    assert_spec [728, 90, "image/jpeg"], ImageSpec.new(fixture('leaderboard.jpg'))
  end

  def test_identifying_gif
    assert_spec [120, 600, "image/gif"], ImageSpec.new(fixture('skyscraper.gif'))
  end

  def test_identifying_png
    assert_spec [120, 600, "image/png"], ImageSpec.new(fixture('skyscraper.png'))
  end

  def test_identifying_swf
    assert_spec [728, 90, "application/x-shockwave-flash"], ImageSpec.new(fixture('leaderboard.swf'))
  end

  def test_corrupted_files
    assert_raises(ImageSpec::Error) { ImageSpec.new(fixture('corrupt.jpg')) }
  end

end
