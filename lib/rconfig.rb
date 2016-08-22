##
#
# Copyright (c) 2009 Rahmal Conda <rahmal@gmail.com>
# -------------------------------------------------------------------
# The complete solution for Ruby Configuration Management. RConfig is a Ruby library that
# manages configuration within Ruby applications. It bridges the gap between yaml, xml, and
# key/value based properties files, by providing a centralized solution to handle application
# configuration from one location. It provides the simplicity of hash-based access, that
# Rubyists have come to know and love, supporting your configuration style of choice, while
# providing many new features, and an elegant API.
#
# -------------------------------------------------------------------
# * Simple, easy to install and use.
# * Supports yaml, xml, and properties files.
# * Yaml and xml files supprt infinite level of configuration grouping.
# * Intuitive dot-notation 'key chaining' argument access.
# * Simple well-known hash/array based argument access.
# * Implements multilevel caching to reduce disk access.
# * Short-hand access to 'global' application configuration, and shell environment.
# * Overlays multiple configuration files to support environment, host, and
#   even locale-specific configuration.
#
# -------------------------------------------------------------------
#  The overlay order of the config files is defined by SUFFIXES:
#  * nil
#  * _local
#  * _config
#  * _local_config
#  * _{environment} (.i.e _development)
#  * _{environment}_local (.i.e _development_local)
#  * _{hostname} (.i.e _whiskey)
#  * _{hostname}_config_local (.i.e _whiskey_config_local)
#
# -------------------------------------------------------------------
#
# Example:
#
#  shell/console =>
#    export LANG=en
#
#  demo.yml =>
#   server:
#     address: host.domain.com
#     port: 81
#  ...
#
#  application.properties =>
#    debug_level = verbose
#  ...
#
# demo.rb =>
#  require 'rconfig'
#  RConfig.load_paths = ['$HOME/config', '#{APP_ROOT}/config', '/demo/conf']
#  RConfig.demo[:server][:port] => 81
#  RConfig.demo.server.address  => 'host.domain.com'
#
#  RConfig[:debug_level] => 'verbose'
#  RConfig[:lang] => 'en'
#  ...
#
require 'active_support'
require 'active_support/hash_with_indifferent_access'
require 'rconfig/core_ext/array'
require 'rconfig/core_ext/hash'
require 'rconfig/core_ext/nil'

module RConfig
  VERSION = '0.5.4'

  autoload :Socket,                    'socket'
  autoload :YAML,                      'yaml'
  autoload :ERB,                       'erb'
  autoload :Logger,                    'logger'
  autoload :Singleton,                 'singleton'

  autoload :Concern,                   'active_support/concern'
  autoload :Hash,                      'active_support/core_ext/hash/conversions'
  autoload :HashWithIndifferentAccess, 'active_support/core_ext/hash/indifferent_access'

  autoload :Config,                    'rconfig/config'
  autoload :Logger,                    'rconfig/logger'
  autoload :Exceptions,                'rconfig/exceptions'
  autoload :Utils,                     'rconfig/utils'
  autoload :Constants,                 'rconfig/constants'
  autoload :Settings,                  'rconfig/settings'
  autoload :ConfigError,               'rconfig/exceptions'
  autoload :LoadPaths,                 'rconfig/load_paths'
  autoload :Cascade,                   'rconfig/cascade'
  autoload :Callbacks,                 'rconfig/callbacks'
  autoload :Reload,                    'rconfig/reload'
  autoload :CoreMethods,               'rconfig/core_methods'
  autoload :PropertiesFile,            'rconfig/properties_file'
  autoload :InstallGenerator,          'generators/rconfig/install_generator'

  extend ActiveSupport::Concern

  extend Utils
  extend Constants
  extend Settings
  extend Exceptions
  extend LoadPaths
  extend Cascade
  extend Callbacks
  extend Reload
  extend CoreMethods
end
