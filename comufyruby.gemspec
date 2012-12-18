# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'comufy/version'

Gem::Specification.new do |gem|
  gem.name          = "comufy"
  gem.version       = Comufy::VERSION
  gem.authors       = %w(plcstevens)
  gem.email         = %w(philip@tauri-tec.com)
  gem.description   = %q{This library can be used with Heroku to connect to Comufy services}
  gem.summary       = %q{This gem is intended to be used on heroku to allow users to easily setup their ruby systems with Comufy services}
  gem.homepage      = "https://github.com/plcstevens/comufyruby"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|spec|features)/})
  gem.require_paths = %w(lib)

  gem.add_development_dependency 'rspec', '~> 2.5'
  gem.add_development_dependency 'rdoc'
end
