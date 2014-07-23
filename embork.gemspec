# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'embork/version'

Gem::Specification.new do |spec|
  spec.name          = 'embork'
  spec.version       = Embork::VERSION
  spec.authors       = ['Mina Smart']
  spec.email         = ['mdsmart@gmail.com']
  spec.description   = %q{A tool set for building ember apps.}
  spec.summary       = %q{A tool set for building ember apps.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sprockets', '~> 2.0'
  spec.add_runtime_dependency 'ember-source', '~> 1.5.1.1'
  spec.add_runtime_dependency 'handlebars-source', '~> 1.3.0'
  spec.add_runtime_dependency 'thor', '~> 0.19.1'
  spec.add_runtime_dependency 'rack'
  spec.add_runtime_dependency 'coffee-script'
  spec.add_runtime_dependency 'sass', '~> 3.2.0'
  spec.add_runtime_dependency 'execjs'
  spec.add_runtime_dependency 'barber'
  spec.add_runtime_dependency 'colorize'
  spec.add_runtime_dependency 'qunit-runner'
  spec.add_runtime_dependency 'phrender'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rspec', '~> 3.0.0.beta1'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rb-fsevent'
  spec.add_development_dependency 'pry', '0.9.12.2'
  spec.add_development_dependency 'compass'
  spec.add_development_dependency 'bootstrap-sass'
  spec.add_development_dependency 'closure-compiler'

end
