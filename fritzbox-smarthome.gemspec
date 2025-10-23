lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fritzbox/smarthome/version'

Gem::Specification.new do |spec|
  spec.name          = 'fritzbox-smarthome'
  spec.version       = Fritzbox::Smarthome::VERSION
  spec.authors       = ['Klaus Meyer']
  spec.email         = ['spam@klaus-meyer.net']

  spec.summary       = 'Client library to interface with Smarthome features of your FritzBox'
  spec.description   = spec.description
  spec.homepage      = 'https://github.com/klausmeyer/fritzbox-smarthome'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|examples)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 7.0', '< 8.1'
  spec.add_dependency 'activemodel', '>= 7.0', '<= 8.1.0'
  spec.add_dependency 'csv', '~> 3.2' # For httparty to silence deprecation warning in ruby >= 3.3.0
  spec.add_dependency 'httparty', '~> 0.20'
  spec.add_dependency 'nori', '~> 2.6'
  spec.add_dependency 'nokogiri', '~> 1.13'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'webmock', '~> 3.14'
  spec.add_development_dependency 'byebug', '~> 11.1'
end
