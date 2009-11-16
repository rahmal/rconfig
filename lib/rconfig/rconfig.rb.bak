require 'socket'
require 'yaml'

require 'rconfig/properties_file_parser'
require 'rconfig/config_hash'
require 'rconfig/core_ext'

##
#=RConfig
#
# * Provides dottable, hash, array, and argument access to YAML 
#   configuration files
# * Implements multilevel caching to reduce disk accesses
# * Overlays multiple configuration files in an intelligent manner
#
# Config file access example:
#  Given a configuration file named test.yaml and test_local.yaml
#  test.yaml:
# ...
# hash_1:
#   foo: "foo"
#   bar: "bar"
#   bok: "bok"
# ...
# test_local.yaml:
# ...
# hash_1:
#   foo: "foo"
#   bar: "baz"
#   zzz: "zzz"
# ...
#
#  irb> RConfig.test
#  => {"array_1"=>["a", "b", "c", "d"], "perform_caching"=>true,
#  "default"=>"yo!", "lazy"=>true, "hash_1"=>{"zzz"=>"zzz", "foo"=>"foo",
#  "bok"=>"bok", "bar"=>"baz"}, "secure_login"=>true, "test_mode"=>true}
#
#  --Notice that the hash produced is the result of merging the above
#  config files in a particular order
#
#  The overlay order of the config files is defined by SUFFIXES:
#  * nil
#  * _local
#  * _config
#  * _local_config
#  * _{environment} (.i.e _development)
#  * _{environment}_local (.i.e _development_local)
#  * _{hostname} (.i.e _whiskey)
#  * _{hostname}_config_local (.i.e _whiskey_config_local)
#
#  ------------------------------------------------------------------
#  irb> RConfig.test_local
#  => {"hash_1"=>{"zzz"=>"zzz", "foo"=>"foo", "bar"=>"baz"}, "test_mode"=>true} 
#
class RConfig
  include Singleton # Don't instantiate this class

  VERSION = '0.1'

  EMPTY_ARRAY = [ ].freeze unless defined? EMPTY_ARRAY
  EMPTY_HASH = { }.freeze unless defined? EMPTY_HASH

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
  unless defined? CONFIG_FILE_TYPE
    CONFIG_FILE_TYPE = (ENV['CONFIG_FILE_TYPE'] || 'yml')
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


  # Define a directory path for searching for config files.
  unless defined? CONFIG_PATH
    # A list of ';' or ':' separated directories to search for
    # config files.
    # Defaults to 'CONFIG_ROOT'.
    CONFIG_PATH = 
      ((x = ENV['CONFIG_PATH']) && ! x.blank? && x) || 
      'CONFIG_ROOT'
  end


  # Returns a list of directories to search for
  # configuration files.
  # 
  # Can be controlled via ENV['CONFIG_PATH']
  # Defaults to [ CONFIG_ROOT ].
  #
  # Example:
  #   CONFIG_PATH="$HOME/work/config:CONFIG_ROOT" script/console
  #
  def self._config_path
    @@_config_path ||=
      begin
        path_sep = (CONFIG_PATH =~ /;/) ? ';' : ':'
        path = CONFIG_PATH.split(/#{path_sep}+/)
        path = 
          path.collect! do | x | 
            x == 'CONFIG_ROOT' ? 
              CONFIG_ROOT : 
              x
          end
        path.freeze
      end
  end


  # Specifies an additional overlay suffix.
  #
  # E.g. 'gb' for UK locale.
  #
  # Defaults from ENV['CONFIG_OVERLAY'].
  def self._overlay
    @@overlay ||= 
      (x = ENV['CONFIG_OVERLAY']) &&
      x.dup.freeze
  end

  def self._overlay=(x)
    _flush_cache if @@overlay != x
    @@overlay = x && x.dup.freeze
  end


  # Returns a list of suffixes to try for a given config name.
  #
  # A config name with an explicit overlay (e.g.: 'name_GB')
  # overrides any current _overlay.
  #
  # This allows code to specifically ask for config overlays
  # for a particular locale.
  #
  def self._suffixes(name)
    name = name.to_s
    @@suffixes[name] ||= 
      begin
        ol = _overlay
        name_x = name.dup
        if name_x.sub!(/_([A-Z]+)$/, '')
          ol = $1
        end
        name_x.freeze
        result = 
        if ol
          ol_ = ol.upcase
          ol = ol.downcase
          x = [ ]
          SUFFIXES.each do | suffix |
            # Standard, no overlay:
            # e.g.: database_<suffix>.yml
            x << suffix

            # Overlay:
            # e.g.: database_(US|GB)_<suffix>.yml
            x << [ ol_, suffix ]
          end
          [ name_x, x.freeze ]
        else
          [ name.dup.freeze, SUFFIXES.freeze ]
        end

        # $stderr.puts "#{name} => #{result.inspect}"
        result.freeze

        result
      end
  end


  # Hash of suffixes for a given config name.
  # @@suffixes['name'] vs @@suffix['name_GB']
  @@suffixes = { }

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
  @@cache_hash = { }

  # The hash holds the same info as @@cache_hash, but it is only
  # loaded once. If reload is disabled, data will from this hash 
  # will always be passed back when RConfig is called.
  @@cache_config_files = { } # Keep around incase reload_disabled.

  # Hash of config base name and the last time it was checked for
  # update.
  # @@last_auto_check['ldap'] = Time.now
  @@last_auto_check = { }

  # Hash of callbacks Procs for when a particular config file has changed.
  @@on_load = { }

  # DON'T CALL THIS IN production.
  def self._flush_cache
    @@suffixes = { }
    @@cache = { } 
    @@cache_files = { } 
    @@cache_hash = { }
    @@last_auto_check = { }
    self
  end

  # Flag indicating whether or not reload should be executed.
  @@reload_disabled = false
  def self._reload_disabled=(x)
    @@reload_disabled = x.nil? ? false : x
  end

  # The number of seconds between reloading of config files
  # and automatic reload checks.
  @@reload_delay = 300
  def self._reload_delay=(x)
    @@reload_delay = x ||
      300
  end

  # Flag indicating whether or not to log errors that occur 
  # in the process of handling config files.
  @@verbose = (ENV['DEBUG_LEVEL'] == 'verbose')
  def self._verbose=(x)
    @@verbose = x.nil? ? false : x;
  end

  # Helper methods for white-box testing and debugging.
  
  # A hash of each file that has been loaded.
  # Can be used for white-box testing or debugging.
  @@config_file_loaded = nil
  def self._config_file_loaded=(x)
    @@config_file_loaded = x
  end
  def self._config_file_loaded
    @@config_file_loaded
  end

  ##
  # Get each config file's yaml hash for the given config name, 
  # to be merged later. Files will only be loaded if they have 
  # not been loaded before or the files have changed within the 
  # last five minutes, or force is explicitly set to true.
  #
  def self.load_config_files(name, force=false)
    name = name.to_s # if name.is_a?(Symbol)

    # Return last config file hash list loaded,
    # if reload is disabled and files have already been loaded.
    return @@cache_config_files[name] if 
      @@reload_disabled && 
      @@cache_config_files[name]

    now = Time.now

    # Get array of all the existing files file the config name.
    config_files = self._get_config_files(name)

    # STDERR.puts "load_config_files(#{name.inspect})"
    
    # Get all the data from all yaml files into as hashes
    hashes = config_files.collect do |f|
      name, name_x, filename, mtime = *f

      # Get the cached file info the specific file, if 
      # it's been loaded before.
      val, last_mtime, last_loaded = @@cache[filename] 

      #if @@verbose && name_x == 'test'
      #  STDERR.puts "f = #{f.inspect}"
      #  STDERR.puts "cache #{name_x} filename = #{filename.inspect}"
      #  STDERR.puts "cache #{name_x} val = #{val.inspect}"
      #  STDERR.puts "cache #{name_x} last_mtime = #{last_mtime.inspect}"
      #  STDERR.puts "cache #{name_x} last_loaded = #{last_loaded.inspect}"
      #end

      # Load the file if its never been loaded or its been more 
      # than 5 minutes since last load attempt.
      if val == nil || 
        now - last_loaded > @@reload_delay
        if force || 
            val == nil || 
            mtime != last_mtime
          
          # STDERR.puts "mtime #{name.inspect} #{filename.inspect} changed #{mtime != last_mtime} : #{mtime.inspect} #{last_mtime.inspect}" if @@verbose && name_x == 'test'

          # mtime is nil if file does not exist.
          if mtime 
            File.open( filename ) do | f |
              STDERR.puts "\nRConfig: loading #{filename.inspect}" if @@verbose
              val = parse_file(f)
              # xml document must have root tag matching the file name to be well-formed.
              val = val[name] if CONFIG_FILE_TYPE == 'xml'
              STDERR.puts "RConfig: loaded #{filename.inspect} => #{val.inspect}" if @@verbose
              (@@config_file_loaded ||= { })[name] = config_files
            end
          end
            
          # Save cached config file contents, and mtime.
          @@cache[filename] = [ val, mtime, now ]
          # STDERR.puts "cache[#{filename.inspect}] = #{@@cache[filename].inspect}" if @@verbose && name_x == 'test'

          # Flush merged hash cache.
          @@cache_hash[name] = nil
                 
          # Config files changed or disappeared.
          @@cache_files[name] = config_files

         end
      end

      val
    end
    hashes.compact!

    # STDERR.puts "load_config_files(#{name.inspect}) => #{hashes.inspect}"

    # Keep last loaded config files around in case @@reload_dsabled.
    @@cache_config_files[name] = hashes

    hashes
  end

  ##
  # Parses file based on file type.
  # 
  def self.parse_file conf_file
    hash = case CONFIG_FILE_TYPE
    when 'yml','yaml'
      YAML::load(conf_file)
    when 'xml'
      Hash.from_xml(conf_file)
    when 'conf','config','properties'
      PropertiesFileParser.parse(conf_file)
    else
      #TODO: Raise real error
      raise "Unknown File type:#{CONFIG_FILE_TYPE}"
    end
    hash.freeze
  end

  ## 
  # Returns a list of all relavant config files as specified
  # by _suffixes list.
  # Each element is an Array, containing:
  #   [ "the-top-level-config-name",
  #     "the-suffixed-config-name",
  #     "/the/absolute/path/to/yaml.yml",
  #     # The mtime of the yml file or nil, if it doesn't exist.
  #   ]
  def self._get_config_files(name) 
    files = [ ]

    _config_path.reverse.each do | dir |
      # alexg: splatting *suffix allows us to deal with multipart suffixes 
      name_no_overlay, suffixes = _suffixes(name)
      suffixes.map { | suffix | [ name_no_overlay, *suffix ].compact.join('_') }.each do | name_x |
        filename = filename_for_name(name_x, dir)
        files <<
        [ name,
          name_x, 
          filename, 
          File.exist?(filename) ? File.stat(filename).mtime : nil, 
        ]
      end
    end

    # $stderr.puts "_get_config_files #{name} => "
    # $stderr.puts "#{files.select{|x| x[3]}.inspect}"

    files
  end

  ##
  # Return the config file information for the given config name.
  #
  def self._config_files(name)
    @@cache_files[name] ||= _get_config_files(name)
  end

  ##
  # Returns whether or not the config for the given config name has changed 
  # since it was last loaded.
  #
  # Returns true if any files for config have changes since
  # last load.
  def self.config_changed?(name)
    # STDERR.puts "config_changed?(#{name.inspect})"
    name = name.to_s # if name.is_a?(Symbol)
    ! (@@cache_files[name] === _get_config_files(name))
  end

  ## 
  # Get the merged config hash for the named file.
  #
  def self.config_hash(name)
    name = name.to_s # if name.is_a?(Symbol)
    _config_hash(name)
  end


  ## 
  # Returns a cached indifferent access faker hash merged
  # from all config files for a name.
  #
  def self._config_hash(name)
    # STDERR.puts "_config_hash(#{name.inspect})"; result = 
    unless result = @@cache_hash[name]
      result = @@cache_hash[name] = 
        _make_indifferent(
                          _merge_hashes(
                                        load_config_files(name)))

      STDERR.puts "_config_hash(#{name.inspect}): reloaded" if @@verbose
      
    end

    result
  end


  ##
  # Register a callback when a config has been reloaded.
  #
  # The config :ANY will register a callback for any config file change.
  #
  # Example:
  #
  #   class MyClass 
  #     @@my_config = { }
  #     RConfig.on_load(:cache) do 
  #       @@my_config = { } 
  #     end
  #     def my_config
  #       @@my_config ||= something_expensive_thing_on_config(RConfig.cache.memory_limit)
  #     end
  #   end
  #
  def self.on_load(*args, &blk)
    args << :ANY if args.empty?
    proc = blk.to_proc

    # Call proc on registration.
    proc.call()

    # Register callback proc.
    args.each do | name |
      name = name.to_s
      (@@on_load[name] ||= [ ]) << proc
    end
  end


  # Do reload callbacks.
  def self._fire_on_load(name)
    callbacks = 
      (@@on_load['ANY'] || EMPTY_ARRAY) + 
      (@@on_load[name] || EMPTY_ARRAY)
    callbacks.uniq!
    STDERR.puts "_fire_on_load(#{name.inspect}): callbacks = #{callbacks.inspect}" if @@verbose && ! callbacks.empty?
    callbacks.each do | cb |
      cb.call()
    end
  end


  # If config files have changed,
  # Caches are flushed, on_load triggers are run.
  def self.check_config_changed(name = nil)
    changed = [ ]

    # STDERR.puts "check_config_changed(#{name.inspect})"
    if name == nil
      @@cache_hash.keys.dup.each do | name |
        if _check_config_changed(name)
          changed << name
        end
      end
    else
      name = name.to_s #  if name.is_a?(Symbol)
      if _check_config_changed(name)
        changed << name
      end
    end
    STDERR.puts "check_config_changed(#{name.inspect}) => #{changed.inspect}" if @@verbose && ! changed.empty?

    changed.empty? ? nil : changed
  end


  def self._check_config_changed(name)
    changed = false

    # STDERR.puts "RConfig: config changed? #{name.inspect} reload_disabled = #{@@reload_disabled}" if @@verbose
    if config_changed?(name) && ! @@reload_disabled 
      STDERR.puts "RConfig: config changed #{name.inspect}" if @@verbose
      if @@cache_hash[name]
        @@cache_hash[name] = nil

        # force on_load triggers.
        _fire_on_load(name)
      end

      changed = true
    end

    changed
  end


  ##
  # Returns a merge of hashes.
  #
  def self._merge_hashes(hashes)
    hashes.inject({ }) { | n, h | n.weave(h, false) }
  end


  ## 
  # Recursively makes hashes into frozen IndifferentAccess ConfigFakerHash
  # Arrays are also traversed and frozen.
  #
  def self._make_indifferent(x)
    case x
    when Hash
      unless x.frozen?
        x.each_pair do | k, v |
          x[k] = _make_indifferent(v)
        end
        x = ConfigHash.new.merge!(x).freeze
      end
      # STDERR.puts "x = #{x.inspect}:#{x.class}"
    when Array
      unless x.frozen?
        x.collect! do | v |
          _make_indifferent(v)
        end
        x.freeze
      end
    # Freeze Strings.
    when String
      x.freeze
    end

    x
  end


  ##
  # This method provides shorthand to retrieve confiuration data that 
  # is global in scope, and used on an application or environment-wide 
  # level. The default location that it checks is the application file.  
  # The application config file is a special config file that should be 
  # used for config data that is broad in scope and used throughout the 
  # application. Since RConfig gives special regard to the application
  # config file, thought should be given to whatever config information 
  # is placed there.
  #
  # Most config data will be specific to particular part of the
  # application (i.e. database, web service), and should therefore
  # be placed in its own specific config file, such as database.yml,
  # or services.xml
  #
  # This method also acts as a wrapper for ENV. If no value is 
  # returned from the application config, it will also check
  # ENV for a value matching the specified key.
  #
  # Ex.1  RConfig[:test_mode] == 
  #        RConfig.application[:test_mode] || 
  #        RConfig.application.test_mode
  #
  # Ex.2  RConfig[:web_app_root] == ENV['WEB_APP_ROOT']
  #       
  # NOTE: The application config file can be in any of 
  #       the supported formats (yml, xml, conf, etc.)
  #
  def self.[](key, file=:application)
    self.get_config_file(file)[key] || ENV[key.to_s.upcase]
  end

  ##
  # Get the value specified by the args, in the file specified by th name 
  #
  def self.with_file(name, *args)
    # STDERR.puts "with_file(#{name.inspect}, #{args.inspect})"; result = 
    args.inject(get_config_file(name)) { | v, i | 
      # STDERR.puts "v = #{v.inspect}, i = #{i.inspect}"
      case v
      when Hash
        v[i.to_s]
      when Array
        i.is_a?(Integer) ? v[i] : nil
      else
        nil
      end
    }
    # STDERR.puts "with_file(#{name.inspect}, #{args.inspect}) => #{result.inspect}"; result
  end
  
  ##
  # Get the merged config hash.
  # Will auto check every 5 minutes, for longer running apps.
  #
  def self.get_config_file(name)
    # STDERR.puts "get_config_file(#{name.inspect})"
    name = name.to_s # if name.is_a?(Symbol)
    now = Time.now
    if (! @@last_auto_check[name]) || (now - @@last_auto_check[name]) > @@reload_delay
      @@last_auto_check[name] = now
      check_config_changed(name)
    end
    # result = 
    _config_hash(name)
    # STDERR.puts "get_config_file(#{name.inspect}) => #{result.inspect}"; result
  end
  
  
  ## 
  # Disables any reloading of config,
  # executes &block, 
  # calls check_config_changed,
  # returns result of block
  #
  def self.disable_reload(&block)
    # This should increment @@reload_disabled on entry, decrement on exit.
    result = nil
    reload_disabled_save = @@reload_disabled
    begin
      @@reload_disabled = true
      result = yield
    ensure
      @@reload_disabled = reload_disabled_save
      check_config_changed unless @@reload_disabled
    end
    result
  end

  ##
  # Creates a dottable hash for all Hash objects, recursively.
  #
  def self.create_dottable_hash(value)
    _make_indifferent(value)
  end

  ##
  # Short-hand access to config file by its name.
  #
  # Example:
  #
  #   RConfig.provider(:foo) => RConfig.with_file(:provider).foo
  #   RConfig.provider.foo   => RConfig.with_file(:provider).foo
  #
  def self.method_missing(method, *args)
    # STDERR.puts "#{self}.method_missing(#{method.inspect}, #{args.inspect})"
    value = with_file(method, *args)
    # STDERR.puts "#{self}.method_missing(#{method.inspect}, #{args.inspect}) => #{value.inspect}"
    value
  end

  ##
  # DO NOT USE in production, if you think you need to use this in production: DONT!!!!
  #
  def self.reload(force = false)
    if force || ! @@reload_disabled
      return unless ['development', 'integration'].include?(ENV_TIER)
      _flush_cache
    end
    nil
  end

  ##
  # Creating an instance isn't required.  But if you just have to a reference to RConfig
  # you can get using RConfig.instance.  It's a singleton, so there's never more than
  # one.  The instamce has no methods of it's own accept what it inherits from object.
  # But it delegates back to the class, so configuration data is still accessible.
  def method_missing(method, *args)
    self.class.method_missing(method, *args)
  end

  def [](key)
    self.class[key]
  end
                   
protected

  ##
  # Get complete file name, including file path for the given config name
  # and directory.
  #
  def self.filename_for_name(name, dir = _config_path[0])
    File.join(dir, name.to_s + '.' + CONFIG_FILE_TYPE)
  end
   
end # RConfig
