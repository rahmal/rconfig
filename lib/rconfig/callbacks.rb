module RConfig
  module Callbacks

    ##
    # Register a callback when a config has been reloaded. If no config name
    # is specified, the callback will be registered under the name :ANY. The
    # name :ANY will register a callback for any config file change.
    #
    # Example:
    #
    #   class MyClass
    #     self.my_config = { }
    #     RConfig.on_load(:cache) do
    #       self.my_config = { }
    #     end
    #     def my_config
    #       self.my_config ||= something_expensive_thing_on_config(RConfig.cache.memory_limit)
    #     end
    #   end
    #
    def on_load(*args, &blk)
      args << :ANY if args.empty?
      proc = blk.to_proc

      # Call proc on registration.
      proc.call()

      # Register callback proc.
      args.each do |name|
        (self.callbacks[name.to_s] ||= []) << proc
      end
    end

    ##
    # Executes all of the reload callbacks registered to the specified config name,
    # and all of the callbacks registered to run on any config, as specified by the
    # :ANY symbol.
    def fire_on_load(name)
      procs = (self.callbacks['ANY'] || RConfig::EMPTY_ARRAY) + (self.callbacks[name] || RConfig::EMPTY_ARRAY)
      procs.uniq!
      logger.debug "fire_on_load(#{name.inspect}): callbacks[#{procs.inspect}]" unless procs.empty?
      procs.each { |proc| proc.call() }
    end

  end
end
