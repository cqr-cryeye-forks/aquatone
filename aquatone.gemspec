# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aquatone/version'

Gem::Specification.new do |spec|
  spec.name          = "aquatone"
  spec.version       = Aquatone::VERSION
  spec.authors       = ["Michael Henriksen"]
  spec.email         = ["michenriksen@neomailbox.ch"]

  spec.summary       = %q{A tool for domain flyovers.}
  spec.homepage      = "https://github.com/michenriksen/aquatone"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency "childprocess"

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
