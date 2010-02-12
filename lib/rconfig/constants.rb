module Constants

  # Sets CONFIG_ROOT to RAILS_ROOT/config unless it has already
  # been defined (i.e. in rails env, or calling ruby app).
  CONFIG_ROOT = RAILS_ROOT + "/config" if defined?(RAILS_ROOT) && defined?(CONFIG_ROOT)

  # ENV TIER i.e. (development, integration, staging, or production)
  # Defaults to RAILS_ENV if running in Rails, otherwise, it checks
  # if ENV['TIER'] is present. If not, it assumes production.
  ENV_TIER = (defined?(RAILS_ENV) ? RAILS_ENV : (ENV['TIER'] || 'production')) unless defined? ENV_TIER

  # yml, yaml => yaml files, parsable by YAML library
  YML_FILE_TYPES = [:yml, :yaml] unless defined? YML_FILE_TYPES

  # xml => self-explanatory
  XML_FILE_TYPES = [:xml] unless defined? XML_FILE_TYPES

  # conf, properties => <key=value> based config files  
  CNF_FILE_TYPES = [:cnf, :conf, :config, :properties] unless defined? CNF_FILE_TYPES
    
  # The type of file used for config. Valid choices
  # include (yml, yaml, xml, conf, config, properties)  
  CONFIG_FILE_TYPES = YML_FILE_TYPES + XML_FILE_TYPES + CNF_FILE_TYPES unless defined? CONFIG_FILE_TYPES

  # Use CONFIG_HOSTNAME environment variable to
  # test host-based configurations.
  HOSTNAME = ENV['CONFIG_HOSTNAME'] || Socket.gethostname unless defined? HOSTNAME

  # Short Hostname: removes all chars from HOSTNAME, after first "."
  # Used to specify machine-specific config files.
  HOSTNAME_SHORT = HOSTNAME.sub(/\..*$/, '').freeze unless defined? HOSTNAME_SHORT

  # This is an array of filename suffixes facilitates overriding
  # configuration (i.e. 'services_local', 'services_development').
  # These files get loaded in order of the array the last file
  # loaded gets splatted on top of everything there.
  # Ex. database_whiskey.yml overrides database_integration.yml
  #     overrides database.yml
  SUFFIXES = [nil,
    :local,
    :config, :local_config,
    ENV_TIER, [ENV_TIER, :local],
    HOSTNAME_SHORT, [HOSTNAME_SHORT, :config_local],
    HOSTNAME, [HOSTNAME, :config_local]
  ] unless defined? SUFFIXES

  # Used in place of undefined but expected arrays,
  # to prevent creating a bunch of unecesary arrays
  # in memory. See ConfigCore.fire_on_load
  EMPTY_ARRAY = [].freeze unless defined? EMPTY_ARRAY

end
