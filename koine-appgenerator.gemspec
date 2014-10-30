# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'koine-app_generator'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 1.9.2'
  s.add_dependency 'bundler', '~> 1.6'
  s.add_dependency("railties", ">= 4.1", "< 5")
  s.add_dependency("rails", ">= 4.1", "< 5")
  s.authors = ['Marcelo Jacobus']
  s.email = 'marcelo.jacobus@gmail.com'
  s.date = Date.today.strftime('%Y-%m-%d')

  s.description = <<-HERE
koine-appgenerator is a custom rails app generator
  HERE

  s.executables = ['koine-appgenerator']
  s.extra_rdoc_files = %w[README.md MIT-LICENSE]
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/mjacobus/koine-appgenerator'
  s.license = 'MIT'
  s.name = 'koine-appgenerator'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.summary = "Generate a rails with Marcelo Jacobus favorites gems and initial settings"
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Koine::Generators::VERSION

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'capybara'
end
