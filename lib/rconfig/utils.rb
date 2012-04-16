module RConfig
  module Utils
    include Constants

    # Used to customize configuration of RConfig. Run 'rails generate rconfig:install' to create
    # a fresh initializer with all configuration values.
    def setup
      yield self
      raise_load_path_error if load_paths.empty?
      self.logger ||= DisabledLogger.new
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
    # Reads and parses the config data from the specified file.
    def read(file, name, ext)
      contents = File.read(file)           # Read the contents from the file.
      contents = ERB.new(contents).result  # Evaluate any ruby code using ERB.
      parse(contents, name, ext)           # Parse the contents based on the file type
    end

    ##
    # Parses contents of the config file based on file type.
    # XML files expect the root element to be the same as the
    # file name.
    #
    def parse(contents, name, ext)
      hash = case ext
        when *YML_FILE_TYPES
          YAML::load(contents)
        when *XML_FILE_TYPES
          parse_xml(contents, name)
        when *CNF_FILE_TYPES
          RConfig::PropertiesFile.parse(contents)
        else
          raise ConfigError, "Unknown File type: #{ext}"
        end
      hash.freeze
    end

    ##
    # Parses xml file and processes any references in the property values.
    def parse_xml(contents, name)
      hash = Hash.from_xml(contents)
      hash = hash[name] if hash.size == 1 && hash.key?(name)  # xml document could have root tag matching the file name.
      RConfig::PropertiesFile.parse_references(hash)
    end

    ##
    # Returns a merge of hashes.
    #
    def merge_hashes(hashes)
      hashes.inject({}) { |n, h| n.weave(h, true) }
    end

    ##
    # Recursively makes hashes into frozen IndifferentAccess Config Hash
    # Arrays are also traversed and frozen.
    #
    def make_indifferent(hash)
      case hash
        when Hash
          unless hash.frozen?
            hash.each do |k, v|
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
        logger.warn "RConfig: Flushing config data cache."
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
    def filename_for_name(name, directory=self.load_paths.first, ext=:yml)
      File.join(directory, "#{name}.#{ext}")
    end



  end
end
