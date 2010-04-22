module Mixins
  module Load

    ##
    # Register a callback when a config has been reloaded. If no config name
    # is specified, the callback will be registered under the name :ANY. The
    # name :ANY will register a callback for any config file change.
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


    ##
    # Sets the flag indicating whether or not reload should be executed.
    def self.allow_reload=(reload)
      raise ArgumentError, 'Argument must be true or false.' unless [true, false].include?(reload)
      @@reload_disabled = (not reload)
    end


    ##
    # Flag indicating whether or not reload should be executed.
    def self.reload?
      !@@reload_disabled
    end


    ##
    # Sets the number of seconds between reloading of config files
    # and automatic reload checks. Defaults to 5 minutes.
    def self.reload_interval=(x)
      raise ArgumentError, 'Argument must be Integer.' unless x.kind_of?(Integer)
      @@reload_interval = (x || 300)
    end


    ##
    # Flushes cached config data, so that it can be reloaded from disk.
    # It is recommended that this should be used with caution, and any
    # need to reload in a production setting should minimized or
    # completely avoided if possible.
    def self.reload(force = false)
      raise ArgumentError, 'Argument must be true or false.' unless [true, false].include?(force)
      if force || reload?
        flush_cache
      end
      nil
    end

    ## 
    # Disables any reloading of config,
    # executes &block, 
    # calls check_config_changed,
    # returns result of block
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

protected

    ##
    # Executes all of the reload callbacks registered to the specified config name,
    # and all of the callbacks registered to run on any config, as specified by the
    # :ANY symbol.
    def self.fire_on_load(name)
      callbacks =
        (@@on_load['ANY'] || EMPTY_ARRAY) +
        (@@on_load[name] || EMPTY_ARRAY)
      callbacks.uniq!
      logger.debug "fire_on_load(#{name.inspect}): callbacks[#{callbacks.inspect}]"  unless callbacks.empty?
      callbacks.each{|cb| cb.call()}
    end

  end
end
