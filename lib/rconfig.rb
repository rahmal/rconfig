#--
# Copyright (c) 2009 Rahmal Conda <rahmal@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

$:.unshift File.dirname(__FILE__)

autoload :Socket, 'socket'
autoload :YAML, 'yaml'
autoload :Logger, 'logger'
autoload :Singleton, 'singleton'

require 'rubygems'
require 'active_support'

autoload :Hash, 'active_support/core_ext/hash/conversions'
autoload :HashWithIndifferentAccess, 'active_support/core_ext/hash/indifferent_access'

require 'rconfig/mixins'
require 'rconfig/core_ext'
require 'rconfig/config_hash'
require 'rconfig/logger'
require 'rconfig/properties_file_parser'
require 'rconfig/exceptions'
require 'rconfig/rconfig'

# Create global reference to RConfig instance
$config = RConfig.instance

