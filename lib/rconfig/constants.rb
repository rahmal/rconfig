module Constants

  # ENV TIER i.e. (development, integration, staging, or production)
  # Defaults to RAILS_ENV if running in Rails, otherwise, it checks
  # if ENV['TIER'] is present. If not, it assumes production.
  unless defined? ENV_TIER
    ENV_TIER = defined?(RAILS_ENV) ? RAILS_ENV : (ENV['TIER'] || 'production')
  end

  # The type of file used for config. Valid choices
  # include (yml, yaml, xml, conf, config, properties)
  #        yml, yaml => yaml files, parsable by YAML library
  # conf, properties => <key=value> based config files
  #              xml => self-explanatory
  # Defaults to yml, if not specified.
  YML_FILE_TYPES = [:yml, :yaml] unless defined? YML_FILE_TYPES
  XML_FILE_TYPES = [:xml] unless defined? XML_FILE_TYPES
  CNF_FILE_TYPES = [:cnf, :conf, :config, :properties] unless defined? CNF_FILE_TYPES
  unless defined? CONFIG_FILE_TYPES
    CONFIG_FILE_TYPES = YML_FILE_TYPES + XML_FILE_TYPES + CNF_FILE_TYPES
  end

  # Use CONFIG_HOSTNAME environment variable to
  # test host-based configurations.
  unless defined? HOSTNAME
    HOSTNAME = ENV['CONFIG_HOSTNAME'] || Socket.gethostname
  end

  # Short hostname: remove all chars after first ".".
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