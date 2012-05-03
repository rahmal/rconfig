#!/usr/bin/env rake

ROOT_DIR = File.expand_path(File.dirname(__FILE__))
CONF_DIR = File.join(ROOT_DIR, 'config')

# Loads the rconfig library
$LOAD_PATH << File.join(ROOT_DIR, 'lib')


require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rconfig'

 
Dir['tasks/**/*.rake'].sort.each { |lib| load lib }

