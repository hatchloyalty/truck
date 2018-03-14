
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'truck/version'

Gem::Specification.new do |spec|
  spec.name          = 'truck'
  spec.version       = Truck::VERSION
  spec.authors       = ['Carl Thuringer']
  spec.email         = ['carl@hatchloyalty.com']

  spec.summary       = 'Move your data around'
  spec.description   = 'Help find out what is wrong with the data'
  spec.homepage      = 'https://hatchloyalty.com'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dotenv', '>= 1.0.0', '< 3'
  spec.add_runtime_dependency 'pg', '>= 0.18', '< 2'
  spec.add_runtime_dependency 'sequel', '>= 5', '< 6'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'sqlite3', '~> 1.3.13'
  spec.add_development_dependency 'pry', '~> 0.11.3'
end
