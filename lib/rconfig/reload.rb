module RConfig
  module Reload

    ##
    # Flag indicating whether or not reload should be executed.
    def reload?
      self.enable_reload
    end

    def reload_disabled?
      not reload?
    end

    ##
    # Sets the flag indicating whether or not reload should be executed.
    def enable_reload=(reload)
      raise ArgumentError, 'Argument must be true or false.' unless [true, false].include?(reload)
      self.enable_reload = reload
    end

    ##
    # Sets the number of seconds between reloading of config files
    # and automatic reload checks. Defaults to 5 minutes. Setting
    #
    def reload_interval=(interval)
      raise ArgumentError, 'Argument must be Integer.' unless interval.kind_of?(Integer)
      self.enable_reload = false if interval == 0  # Sett
      self.reload_interval = interval
    end

    ##
    # Flushes cached config data, so that it can be reloaded from disk.
    # It is recommended that this should be used with caution, and any
    # need to reload in a production setting should minimized or
    # completely avoided if possible.
    def reload(force=false)
      raise ArgumentError, 'Argument must be true or false.' unless [true, false].include?(force)
      if force || reload?
        flush_cache
        return true
      end
      false
    end

    ##
    # Executes given block, without reloading any config. Meant to
    # run configuration-sensitive code that may otherwise trigger a
    # reload of any/all config files. If reload is disabled then it
    # makes no difference  if this wrapper is used or not.
    # Returns result of the block
    def without_reload(&block)
      return unless block_given?
      result = nil
      enable_reload_cache = self.enable_reload
      begin
        self.enable_reload
        result = yield
      ensure
        self.enable_reload = enable_reload_cache
        check_config_changed if reload?
      end
      result
    end

    def auto_check?(name)
      now = Time.now
      if (!self.last_auto_check[name]) || (now - self.last_auto_check[name]) > self.reload_interval
        self.last_auto_check[name] = now
        return true
      end
      return false
    end
    
  end
end
