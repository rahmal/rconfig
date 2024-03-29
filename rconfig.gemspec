# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rconfig"

Gem::Specification.new do |s|

  # Metadata
  s.name          = 'rconfig'
  s.version       = RConfig::VERSION
  s.authors       = ['Rahmal Conda']
  s.email         = ['rahmal@gmail.com']
  s.homepage      = 'http://rahmal.github.com/rconfig'
  s.description   = %q{Configuration management library for Ruby applications.}
  s.summary       = %q{The complete solution for Ruby Configuration Management. RConfig is a Ruby library that manages configuration within Ruby applications. It bridges the gap between yaml, xml, and key/value based properties files, by providing a centralized solution to handle application configuration from one location. It provides the simplicity of hash-based access, that Rubyists have come to know and love, supporting your configuration style of choice, while providing many new features, and an elegant API.}
  s.licenses      = ['MIT']

  # Manifest
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # Dependencies
  s.add_dependency 'activesupport',       '>= 3.2', '< 8.0'
  s.add_dependency 'json',                '>  1.8.1'

  # Development Dependencies
  s.add_development_dependency 'rake',    '~> 12.3'
  s.add_development_dependency 'rack',    '~> 2.1.4'
  s.add_development_dependency 'rspec',   '>  2.3.0'
  s.add_development_dependency 'bundler', '>  1.0.0'
  s.add_development_dependency 'jeweler', '>  1.6.4'
  s.add_development_dependency 'i18n'  
end

