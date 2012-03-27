module RConfig
  module Constants

    # Sets CONFIG_ROOT to RAILS_ROOT/config unless it has already
    # been defined (i.e. in rails env, or calling ruby app).
    CONFIG_ROOT = File.join(Rails.root, 'config') if defined?(::Rails) && !defined?(CONFIG_ROOT)

    # ENV TIER i.e. (development, integration, staging, or production)
    # Defaults to RAILS_ENV if running in Rails, otherwise, it checks
    # if ENV['TIER'] is present. If not, it assumes production.
    ENV_TIER = (defined?(RAILS_ENV) ? RAILS_ENV : (ENV['TIER'] || 'production')) unless defined? ENV_TIER

    # yml, yaml => yaml files, parsable by YAML library
    YML_FILE_TYPES = [:yml, :yaml].freeze unless defined? YML_FILE_TYPES

    # xml => self-explanatory
    XML_FILE_TYPES = [:xml].freeze unless defined? XML_FILE_TYPES

    # conf, properties => <key=value> based config files  
    CNF_FILE_TYPES = [:cnf, :conf, :config, :properties].freeze unless defined? CNF_FILE_TYPES

    # The type of file used for config. Valid choices
    # include (yml, yaml, xml, conf, config, properties)  
    CONFIG_FILE_TYPES = (YML_FILE_TYPES + XML_FILE_TYPES + CNF_FILE_TYPES).freeze unless defined? CONFIG_FILE_TYPES

    # Use CONFIG_HOSTNAME environment variable to
    # test host-based configurations.
    HOSTNAME = ENV['CONFIG_HOSTNAME'] || Socket.gethostname unless defined? HOSTNAME

    # Short Hostname: removes all chars from HOSTNAME, after first "."
    # Used to specify machine-specific config files.
    HOSTNAME_SHORT = HOSTNAME.sub(/\..*$/, '').freeze unless defined? HOSTNAME_SHORT

    # This is an array of filename suffixes facilitates cascading
    # configuration overrides (i.e. 'services_local', 'services_development').
    # These files get loaded in the order of the array. Meaning the last file
    # loaded overrides everything before it. So config files suffixed with
    # hostname has the highest precedence, and therefore overrides everything.
    # Example: 
    #          database_local.yml overrides database.yml
    #          database_staging.yml overrides database_local.yml
    #          database_appsvr01.yml overrides database_integration.yml
    SUFFIXES = [
      nil,                                                # Empty suffix, used for default config file (i.e. database.yml).
      :local,                                             # Allows user to create 'local' overrides (i.e. database_local.yml), primarily used for development.
      :config, :local_config,
      ENV_TIER, [ENV_TIER, :local],                       # Environment configs (i.e. development, test, production).
      HOSTNAME_SHORT, [HOSTNAME_SHORT, :config_local],    # Short hostname (i.e. appsvr01), for server-specific configs.
      HOSTNAME, [HOSTNAME, :config_local]                 # Hostname (i.e. appsvr01.acme.com), for server/domain-specific configs.
    ] unless defined? SUFFIXES

    # Used in place of undefined but expected arrays,
    # to prevent creating a bunch of unecesary arrays
    # in memory. See ConfigCore.fire_on_load
    EMPTY_ARRAY = [].freeze unless defined? EMPTY_ARRAY
    
  end
end