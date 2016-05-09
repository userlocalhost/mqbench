# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mqbench/version'

Gem::Specification.new do |spec|
  spec.name          = "mqbench"
  spec.version       = Mqbench::VERSION
  spec.authors       = ["Hiroyasu OHYAMA"]
  spec.email         = ["user.localhost2000@gmail.com"]

  spec.summary       = %q{A benchmark client for MOM}
  spec.description   = %q{This aims to be a common benchmark tool for MOM}
  spec.homepage      = "https://github.com/userlocalhost2000/mqbench"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "stomp", "~> 1.3"
  spec.add_runtime_dependency "bunny", "~> 2.3"
  spec.add_runtime_dependency "ruby-kafka", "~> 0.3.6"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
end
