#!/usr/bin/env rake

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rubygems'
require 'echoe'
require 'hoe'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'lib/rconfig'

Hoe.new('rconfig', RConfig::VERSION) do |p|
  p.developer( 'Rahmal Conda', 'rahmal@gmail.com' )
  
end


=begin
spec = Gem::Specification.new do |s| 
  s.name = "ActiveControl"
  s.version = "0.0.1"
  s.author = "Rahmal Conda"
  s.email = "rahmal@gmail.com"
  s.homepage = "http://www.rahmalconda.com"
  s.platform = Gem::Platform::RUBY
  s.summary = ""
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = "name"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.add_dependency("dependency", ">= 0.x.x")
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end 
=end
