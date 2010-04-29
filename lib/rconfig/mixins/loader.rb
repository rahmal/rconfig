module Mixins
  module Loader

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
    # Sets the flag indicating whether or not reload should be executed.
    def self.allow_reload=(reload)
      raise ArgumentError, 'Argument must be true or false.' unless [true, false].include?(reload)
      @@reload_disabled = (not reload)
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

  end
end
