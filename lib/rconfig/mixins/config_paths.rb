module Mixins
  module ConfigPaths

    ##
    # Sets the list of directories to search for
    # configuration files.
    # The argument must be an array of strings representing
    # the paths to the directories, or a string representing
    # either a single path or a list of paths separated by
    # either a colon (:) or a semi-colon (;).
    # If reload is disabled, it can only be set once.
    def self.config_paths=(paths)
      return if @@reload_disabled && config_paths_set?
      if paths.is_a? String
        path_sep = (paths =~ /;/) ? ';' : ':'
        paths = paths.split(/#{path_sep}+/)
      end
      unless paths.is_a? Array
        raise ArgumentError,
              "Path(s) must be a String or an Array [#{paths.inspect}]"
      end
      if paths.empty?
        raise ArgumentError,
              "Must provide at least one paths: [#{paths.inspect}]"
      end
      paths.all? do |dir|
        dir = CONFIG_ROOT if dir == 'CONFIG_ROOT'
        unless File.directory?(dir)
          raise InvalidConfigPathError,
                "This directory is invalid: [#{dir.inspect}]"
        end
      end
      reload
      @@config_paths = paths
    end

    class << self;
      alias_method :set_config_paths, :config_paths=
    end

    ##
    # Adds the specified path to the list of directories to search for
    # configuration files.
    # It only allows one path to be entered at a time.
    # If reload is disabled, it can onle be set once.
    def self.set_config_path path
      return if @@reload_disabled && config_paths_set?
      return unless path.is_a?(String) # only allow string argument
      path_sep = (path =~ /;/) ? ';' : ':' # if string contains multiple paths
      path = path.split(/#{path_sep}+/)[0] # only accept first one.

      if @@config_paths.blank?
        set_config_paths(path)
      else
        config_paths << path if File.directory?(path)
        reload
        @@config_paths
      end
    end

    class << self;
      alias_method :add_config_path, :set_config_path
    end

    ##
    # Returns a list of directories to search for
    # configuration files.
    # 
    # Can be preset with config_paths=/set_config_path, 
    # controlled via ENV['CONFIG_PATH'], 
    # or defaulted to CONFIG_ROOT (assumming some sort of 
    # application initiation as in RAILS).
    # Defaults to [ CONFIG_ROOT ].
    #
    # Examples:
    #   export CONFIG_PATH="$HOME/work/config:CONFIG_ROOT" 
    #   CONFIG_ROOT = RAILS_ROOT + "/config" unless defined? CONFIG_ROOT
    #
    def self.config_paths
      return @@config_paths unless @@config_paths.blank?

      begin
        config_paths = ENV['CONFIG_PATH']
      rescue
        logger.error {
          "Forget something? No config paths! ENV['CONFIG_PATH'] is not set.\n" +
              "Hint:  Use config_paths= or set_config_path."
        }
      end

      begin
        config_paths = [CONFIG_ROOT]
      rescue
        logger.error {
          "Forget something?  No config paths! CONFIG_ROOT is not set.\n" +
              "Hint:  Use config_paths= or set_config_path."
        }
      end

      if @@config_paths.blank?
        raise InvalidConfigPathError,
              "Forget something?  No config paths!\n" +
                  "Niether ENV['CONFIG_PATH'] or CONFIG_ROOT is set.\n" +
                  "Hint:  Use config_paths= or set_config_path."
      end

      @@config_paths
    end


    ##
    # Indicates whether or not config_paths have been set.
    # Returns true if @@config_paths has at least one directory.
    def self.config_paths_set?
      !@@config_paths.blank?
    end

  end
end
