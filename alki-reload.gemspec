# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alki/reload/version'

Gem::Specification.new do |spec|
  spec.name          = "alki-reload"
  spec.version       = Alki::Reload::VERSION
  spec.authors       = ["Matt Edlefsen"]
  spec.email         = ["matt.edlefsen@gmail.com"]

  spec.summary       = %q{Automatic reloading of alki projects}
  spec.homepage      = "https://github.com/alki-project/alki-reload"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.1.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "listen", "~> 3.0"
  spec.add_dependency "alki", "~> 0.14.0"
end
