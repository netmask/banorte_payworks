# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'banorte_payworks/version'

Gem::Specification.new do |spec|
  spec.name          = 'banorte_payworks'
  spec.version       = BanortePayworks::VERSION
  spec.authors       = ['Jonathan Garay']
  spec.email         = %w(jonathan@devmask.net)
  spec.description   = %q{Simple TPV for Banorte Payworks Mexican Gateway}
  spec.summary       = %q{Simple TPV implementation for Banorte Payworks}
  spec.homepage      = 'http://devmask.net/banorte_payworks/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'httpclient', '>= 2.3.3'
  spec.add_dependency 'faraday'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

end
