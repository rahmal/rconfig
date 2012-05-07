require 'rubygems'
require 'bundler'
require 'rspec/core/rake_task'

Bundler.setup
Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

Dir['lib/tasks/**/*.rake'].sort.each { |lib| load lib }
