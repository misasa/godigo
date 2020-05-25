# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'godigo/version'

Gem::Specification.new do |spec|
  spec.name          = "godigo"
  spec.version       = Godigo::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]

  spec.summary       = %q{Godigo}
  spec.description   = %q{Command-line tools for Godigo}
  spec.homepage      = "http://dream.misasa.okayama-u.ac.jp"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
#  spec.add_development_dependency "simplecov-rcov"
#  spec.add_development_dependency "rspec_junit_formatter"

  spec.add_dependency "machine_time_client", "~> 1.0.1"
  spec.add_dependency 'unindent'
end
