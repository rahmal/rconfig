module RConfig
  module Utils
    include Constants

    # Used to customize configuration of RConfig. Run 'rails generate rconfig:install' to create
    # a fresh initializer with all configuration values.
    def setup
      yield self
      raise_load_path_error if load_paths.empty?
      logger ||= DisabledLogger.new
    end

    # Creates a class variable a sets it to the default value specified.
    def setting(name, default=nil)
      RConfig.class_eval <<-EOC, __FILE__, __LINE__ + 1
        def self.#{name}
          @@#{name}
        end
        def self.#{name}=(val)
          @@#{name} = val
        end
      EOC

      RConfig.send(:"#{name}=", default)
    end

    # Checks environment for default configuration load paths.  Adds them to load paths if found.
    def default_load_paths
      paths = []

      # Check for Rails config path
      paths << "#{::Rails.root}/config" if rails?

      # Check for defined constants
      paths << CONFIG_ROOT if defined?(CONFIG_ROOT) && Dir.exists?(CONFIG_ROOT)
      paths << CONFIG_PATH if defined?(CONFIG_PATH) && Dir.exists?(CONFIG_PATH)

      # Check for config directory in app root
      config_dir = File.join(app_root, 'config')
      paths << config_dir if Dir.exists?(config_dir)

      paths
    end

    ##
    #  Returns true if the current application is a rails app.
    def rails?
      !!defined?(::Rails)
    end

    ##
    #
    def app_root
      File.expand_path(File.dirname(__FILE__))
    end

    ##
    # Helper method for white-box testing and debugging.
    # Sets the flag indicating whether or not to log
    # errors and application run-time information.
    def log_level=(level)
      return unless logger
      logger.level = level unless level.nil?
    end

    def log_level
      logger.try(:level)
    end

    ##
    # Creates a dottable hash for all Hash objects, recursively.
    def create_dottable_hash(hash)
      make_indifferent(hash)
    end

    ##
    # Parses file based on file type.
    #
    def parse_file(conf_file, ext)
      hash = case ext
        when * YML_FILE_TYPES
          YAML::load(conf_file)
        when * XML_FILE_TYPES
          Hash.from_xml(conf_file)
        when * CNF_FILE_TYPES
          RConfig::PropertiesFileParser.parse(conf_file)
        else
          raise ConfigError, "Unknown File type:#{ext}"
        end
      hash.freeze
    end

    ##
    # Returns a merge of hashes.
    #
    def merge_hashes(hashes)
      hashes.inject({}) { |n, h| n.weave(h, true) }
    end

    ##
    # Recursively makes hashes into frozen IndifferentAccess ConfigFakerHash
    # Arrays are also traversed and frozen.
    #
    def make_indifferent(hash)
      case hash
        when Hash
          unless hash.frozen?
            hash.each_pair do |k, v|
              hash[k] = make_indifferent(v)
            end
            hash = RConfig::Config.new.merge!(hash).freeze
          end
          logger.debug "make_indefferent: x = #{hash.inspect}:#{hash.class}"
        when Array
          unless hash.frozen?
            hash.collect! do |v|
              make_indifferent(v)
            end
            hash.freeze
          end
          # Freeze Strings.
        when String
          hash.freeze
        end
      hash
    end

    ##
    # If a config file name is specified, flushes cached config values
    # for specified config file. Otherwise, flushes all cached config data.
    # The latter should be avoided in production environments, if possible.
    def flush_cache(name=nil)
      if name
        name = name.to_s
        self.cache_hash[name] &&= nil
      else
        logger.warn "Flushing complete config data cache."
        self.suffixes        = {}
        self.cache           = {}
        self.cache_files     = {}
        self.cache_hash      = {}
        self.last_auto_check = {}
        self
      end
    end

    ##
    # Get complete file name, including file path for the given config name
    # and directory.
    def filename_for_name(name, dir=self.load_paths.first, ext=:yml)
      File.join(dir, "#{name}.#{ext}")
    end



  end
end
