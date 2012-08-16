# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.1'
  s.required_rubygems_version = ">= 1.3.6"

  s.name        = "ruby-imagespec"
  s.summary     = "Image/Flash extract width/height dimensions extractor"
  s.version     = "0.3.0"

  s.authors     = ["Brandon Anderson", "Michael Sheakoski", "Mike Boone", "Dimitrij Denissenko"]
  s.email       = "dimitrij@blacksquaremedia.com"
  s.homepage    = "http://github.com/dim/ruby-imagespec"

  s.require_path = 'lib'
  s.files        = Dir['VERSION', 'README', 'init.rb', 'lib/**/*']

  s.add_development_dependency 'rake'
end

