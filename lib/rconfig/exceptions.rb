##
# Copyright (c) 2009 Rahmal Conda <rahmal@gmail.com>
#
# RConfig Exceptions
#
module RConfig
  # General error in config initialization or operation.
  class ConfigError < StandardError; end

  # Load path(s) are not set, don't exist, or Invalid in some manner
  class InvalidLoadPathError < ConfigError; end

  module Exceptions

    # Raised when no valid load paths are available.
    def raise_load_path_error
      raise InvalidLoadPathError, "No load paths were provided, and none of the default paths were found."
    end

    # Raised if logging is enabled, but no logger is specified}.
    def raise_logger_error
      raise ConfigError, "No logger was specified, and a defualt logger was not found. Set logger to `false` to disable logging."
    end

  end
end
