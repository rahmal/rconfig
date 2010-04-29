##
# Copyright (c) 2009 Rahmal Conda <rahmal@gmail.com>
#
# RConfig Exceptions
#
#--
# General error in config initialization or operation.
class ConfigError < StandardError;
end

# Config path(s) are not set, don't exist, or Invalid in some manner
class InvalidConfigPathError < ConfigError;
end

