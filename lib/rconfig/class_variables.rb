module ClassVariables

  # The list of directories to search for configuration files.
  @@config_paths = []

  # Hash of suffixes for a given config name.
  # @@suffixes['name'] vs @@suffix['name_GB']
  @@suffixes = {}

   @@overlay = ENV['CONFIG_OVERLAY'] || ""

  # Hash of yaml file names and their respective contents,
  # last modified time, and the last time it was loaded.
  # @@cache[filename] = [yaml_contents, mod_time, time_loaded]
  @@cache = {}

  # Hash of config file base names and their existing filenames
  # including the suffixes.
  # @@cache_files['ldap'] = ['ldap.yml', 'ldap_local.yml', 'ldap_<hostname>.yml']
  @@cache_files = {}

  # Hash of config base name and the contents of all its respective
  # files merged into hashes. This hash holds the data that is
  # accessed when RConfig is called. This gets re-created each time
  # the config files are loaded.
  # @@cache_hash['ldap'] = config_hash
  @@cache_hash = {}

  # The hash holds the same info as @@cache_hash, but it is only
  # loaded once. If reload is disabled, data will from this hash
  # will always be passed back when RConfig is called.
  @@cache_config_files = {} # Keep around incase reload_disabled.

  # Hash of config base name and the last time it was checked for
  # update.
  # @@last_auto_check['ldap'] = Time.now
  @@last_auto_check = {}

  # Hash of callbacks Procs for when a particular config file has changed.
  @@on_load = {}

  # The number of seconds between reloading of config files
  # and automatic reload checks. Defaults to 5 minutes.
  @@reload_interval = 300

  # Flag variable indicating whether or not reload should be executed.
  # Defaults to false.
  @@reload_disabled = false

  # Helper variable for white-box testing and debugging.
  # A hash of each file that has been loaded.
  @@config_file_loaded = nil

  # Flag indicating whether or not to log errors and
  # errors and application run-time information. It
  # defaults to environment debug level setting, or
  # false if the env variable is not set.
  @@verbose = (ENV['DEBUG_LEVEL'] == 'verbose')

end