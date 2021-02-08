lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'stak/version'

Gem::Specification.new do |spec|
  spec.name          = 'stak'
  spec.version       = Stak::VERSION
  spec.authors       = ['Daniel Jarrett']
  spec.email         = ['djarrett@alumni.princeton.edu']
  spec.summary       = %q{A Rack-based MVC Web Framework}
  spec.description   = %q{A flexible, minimal, MVC web-application framework}
  spec.homepage      = 'http://github.com/danieljarrett/stak-framework'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'rack', '~> 1.5'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'sqlite3', '~> 1.3'
end
