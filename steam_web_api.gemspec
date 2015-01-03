# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'steam_web_api/version'

Gem::Specification.new do |spec|
  spec.name          = "steam_web_api"
  spec.version       = SteamWebApi::VERSION
  spec.authors       = ["Olga Grabek"]
  spec.email         = ["olga.grabek@gmail.com"]
  spec.summary       = %q{This is gem that it makes trivial to use Steam Web API}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
