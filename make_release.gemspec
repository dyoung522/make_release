# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'make_release/globals'

Gem::Specification.new do |spec|
  spec.name          = MakeRelease::Globals::IDENT
  spec.version       = MakeRelease::Globals::VERSION
  spec.authors       = [MakeRelease::Globals::AUTHOR]
  spec.email         = [MakeRelease::Globals::AEMAIL]

  spec.summary       = MakeRelease::Globals::SUMMARY
  spec.description   = MakeRelease::Globals::DESCRIPTION
  spec.homepage      = MakeRelease::Globals::HOMEPAGE
  spec.license       = MakeRelease::Globals::LICENSE

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = ['mkrelease']
  spec.require_paths = ['./lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

