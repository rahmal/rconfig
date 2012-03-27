module RConfig
  module Settings
    extend Constants

    ### Configuration Settings ====>

    # Load paths for configuration files. Add folders to this load path
    # to load up other resources for administration. External gems can
    # include their paths in this load path to provide active_admin UIs
    setting :load_paths,          default_load_paths

    # Custom cascade used when cascading configurations to override default
    # config files. Can be used to add locale or branch specific configs.
    setting :overlay,             false

    # The type of configuration files to load Supported file types are yaml,
    # xml, and property files (.property).
    setting :file_types,          CONFIG_FILE_TYPES

    # The logger rconfig will log to.
    setting :logger,              RConfig::Logger.new

    # Indicates whether or not periodic reloads should be performed.
    setting :enable_reload,       false

    # How often periodic reloads should be performed in seconds.
    # The number of seconds between reloading of config files
    # and automatic reload checks. Defaults to 5 minutes.
    setting :reload_interval,     300  # 5 min

    ### Initialize Configuration Cache ====>

    # Primary configuration cache for RConfig.
    # Hash of yaml file names and their respective contents,
    # last modified time, and the last time it was loaded.
    # self.cache[filename] = [yaml_contents, mod_time, time_loaded]
    setting :cache,               {}

    # File cache used to store loaded configuration files.
    # Hash of config file base names and their existing filenames
    # including the suffixes.
    # self.cache_files['ldap'] = ['ldap.yml', 'ldap_local.yml', 'ldap_<hostname>.yml']
    setting :cache_files,         {}

    # Cache key-value lookup
    # Hash of config base name and the contents of all its respective
    # files merged into hashes. This hash holds the data that is
    # accessed when RConfig is called. This gets re-created each time
    # the config files are loaded.
    # self.cache_hash['ldap'] = config_hash
    setting :cache_hash,          {}

    # This hash holds the same info as self.cache_hash, but it is only
    # loaded once. If reload is disabled, data will from this hash
    # will always be passed back when RConfig is called.
    setting :cache_config_files,  {}

    # Hash of suffixes for a given cascading configuration name.
    # The suffixes are used to load cascading configurations for
    # a specified name.
    # Example:
    #   self.suffixes[:name] #=> %w[ name_development name_staging name_production name_GB ]
    setting :suffixes,            {}

    # Hash of callbacks, mapped to a given config file. Each collection of procs are
    # executed when the config file they are mapped to has been reloaded.
    setting :callbacks,           {}

    # Hash of config base name and the last time it was checked for
    # update.
    # self.last_auto_check['ldap'] = Time.now
    setting :last_auto_check,     {}

    # Helper variable for white-box testing and debugging.
    # A hash of each file that has been loaded.
    setting :config_loaded

    # Magically unique value. Used to provide a key to retrieve a default value
    # specified in a config file. The symbol is wrapped in an array so that it will
    # not be treated like a normal key and changed to a string.
    #
    # Example:
    #          currency:
    #            us: dollar
    #            gb: pound
    #            default: dollar
    #
    #          RConfig.currency.ca => 'dollar'
    setting :default_key,         [:default_key].freeze

  end
end
