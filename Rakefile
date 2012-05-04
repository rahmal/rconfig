require 'rubygems'
require 'bundler'
require 'rspec/core/rake_task'

Bundler.setup
Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new do |spec|
  # spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

#$LOAD_PATH << File.join(ROOT_DIR, 'lib')
Dir['lib/tasks/**/*.rake'].sort.each { |lib| load lib }



#!/usr/bin/env rake
#ROOT_DIR = File.expand_path(File.dirname(__FILE__))
#CONF_DIR = File.join(ROOT_DIR, 'config')
# Loads the rconfig library
#$LOAD_PATH << File.join(ROOT_DIR, 'lib')
#require 'rubygems'
#require 'rake'
#require 'rdoc/'
#require 'rdoc/task'
#require 'rconfig'
#Dir['lib/tasks/**/*.rake'].sort.each { |lib| load lib }

