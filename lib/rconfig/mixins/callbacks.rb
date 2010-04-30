module Mixins
  module Callbacks

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
      args.each do |name|
        name = name.to_s
        (@@on_load[name] ||= []) << proc
      end
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
      logger.debug "fire_on_load(#{name.inspect}): callbacks[#{callbacks.inspect}]" unless callbacks.empty?
      callbacks.each { |cb| cb.call() }
    end

  end
end
