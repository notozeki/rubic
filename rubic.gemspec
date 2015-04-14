# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubic/version'

Gem::Specification.new do |spec|
  spec.name          = "rubic"
  spec.version       = Rubic::VERSION
  spec.authors       = ["notozeki"]
  spec.email         = ["notozeki@gmail.com"]

  spec.summary       = %q{A tiny Scheme interpreter}
  spec.description   = %q{Rubic is a very simple Scheme interpreter written in Ruby.}
  spec.homepage      = "https://github.com/notozeki/rubic"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.executables   = ['rubic']

  spec.required_ruby_version = '>= 2.1' # for Refinements

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.5"
  spec.add_development_dependency 'travis', '~> 1.7'
  spec.add_development_dependency 'coveralls', '~> 0.8'

  spec.add_dependency "racc", "~> 1.4"
end
