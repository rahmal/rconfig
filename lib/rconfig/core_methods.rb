##
# Copyright (c) 2009 Rahmal Conda <rahmal@gmail.com>
#
module RConfig
  module CoreMethods
    include Constants

    ##
    # Get each config file's yaml hash for the given config name,
    # to be merged later. Files will only be loaded if they have
    # not been loaded before or the files have changed within the
    # last five minutes, or force is explicitly set to true.
    #
    def load_config_files(name, force=false)
      name = name.to_s

      # Return last config file hash list loaded,
      # if reload is disabled and files have already been loaded.
      return self.cache_config_files[name] if self.reload_disabled? && self.cache_config_files[name]

      logger.info "Loading config files for: #{name}"
      logger.debug "load_config_files(#{name.inspect})"


      now = Time.now

      # Get array of all the existing files file the config name.
      config_files = self.get_config_files(name)

      # Get all the data from all yaml files into as configs
      configs = config_files.collect do |f|
        name, name_with_suffix, filename, ext, modified_time = * f

        # Get the cached file info the specific file, if
        # it's been loaded before.
        config_data, last_modified, last_loaded = self.cache[filename]

        logger.debug "f = #{f.inspect}\n" +
          "cache #{name_with_suffix} filename      = #{filename.inspect}\n" +
          "cache #{name_with_suffix} config_data   = #{config_data.inspect}\n" +
          "cache #{name_with_suffix} last_modified = #{last_modified.inspect}\n" +
          "cache #{name_with_suffix} last_loaded   = #{last_loaded.inspect}\n"

        # Load the file if its never been loaded or its been more than
        # so many minutes since last load attempt. (default: 5 minutes)
        if config_data.blank? || (now - last_loaded > self.reload_interval)
          if force || config_data.blank? || modified_time != last_modified

            logger.debug "modified_time #{name.inspect} #{filename.inspect} " +
              "changed #{modified_time != last_modified} : #{modified_time.inspect} #{last_modified.inspect}"

            logger.debug "RConfig: loading #{filename.inspect}"

            config_data = read(filename, name, ext)  # Get contents from config file

            logger.debug "RConfig: loaded #{filename.inspect} => #{config_data.inspect}"

            (self.config_loaded ||= {})[name] = config_files  # add files to the loaded files cache

            self.cache[filename] = [config_data, modified_time, now]  # Save cached config file contents, and modified_time.

            logger.debug "cache[#{filename.inspect}] = #{self.cache[filename].inspect}"

            self.cache_hash[name] = nil # Flush merged hash cache.

            self.cache_files[name] = config_files  # Config files changed or disappeared.

          end # if config_data == nil || (now - last_loaded > self.reload_interval)
        end # if force || config_data == nil || modified_time != last_modified

        config_data
      end # config_files.collect
      configs.compact!

      logger.debug "load_config_files(#{name.inspect}) => #{configs.inspect}"

      # Keep last loaded config files around in case self.reload_dsabled.
      self.cache_config_files[name] = configs #unless configs.empty?

      configs
    end


    ##
    # Returns a list of all relevant config files as specified by suffixes list.
    # Each element is an Array, containing:
    #
    #   [ 
    #     "server",              # The base name of the 
    #     "server_production",   # The suffixed name
    #     "/path/to/server.yml", # The absolute path to the file 
    #     <Wed Apr 09 08:53:14>  # The last modified time of the file or nil, if it doesn't exist.
    #   ]
    #
    def get_config_files(name)
      files = []

      self.load_paths.reverse.each do |directory|
        # splatting *suffix allows us to deal with multipart suffixes
        name_no_overlay, suffixes = suffixes_for(name)
        suffixes.map { |suffix| [name_no_overlay, *suffix].compact.join('_') }.each do |name_with_suffix|
          self.file_types.each do |ext|
            filename = filename_for_name(name_with_suffix, directory, ext)
            if File.exists?(filename)
              modified_time = File.stat(filename).mtime
              files << [name, name_with_suffix, filename, ext, modified_time]
            end
          end
        end
      end

      logger.debug "get_config_files(#{name}) => #{files.select { |x| x[3] }.inspect}"

      files
    end

    ##
    # Return the config file information for the given config name.
    #
    def config_files(name)
      self.cache_files[name] ||= get_config_files(name)
    end


    ##
    # Returns whether or not the config for the given config name has changed
    # since it was last loaded.
    #
    # Returns true if any files for config have changes since
    # last load.
    def config_changed?(name)
      logger.debug "config_changed?(#{name.inspect})"
      name = name.to_s
      !(self.cache_files[name] === get_config_files(name))
    end


    ##
    # Get the merged config hash for the named file.
    # Returns a cached indifferent access faker hash merged
    # from all config files for a name.
    #
    def get_config_data(name)
      logger.debug "get_config_data(#{name.inspect})"

      name = name.to_s
      unless result = self.cache_hash[name]
        result = self.cache_hash[name] =
            make_indifferent(
                merge_hashes(
                    load_config_files(name)
                )
            )
        logger.debug "get_config_data(#{name.inspect}): reloaded"
      end

      result
    end

    ##
    # If name is specified, checks that file for changes and
    # reloads it if there are.  Otherwise, checks all files
    # in the cache, reloading the changed files.
    def check_for_changes(name=nil)
      changed = []
      if name == nil
        self.cache_hash.keys.dup.each do |name|
          if reload_on_change(name)
            changed << name
          end
        end
      else
        name = name.to_s
        if reload_on_change(name)
          changed << name
        end
      end
      logger.debug "check_for_changes(#{name.inspect}) => #{changed.inspect}"
      changed
    end

    ##
    # If config files have changed, caches are flushed, on_load triggers are run.
    def reload_on_change(name)
      logger.debug "reload_on_change(#{name.inspect}), reload_disabled=#{self.reload_disabled?}"
      if changed = config_changed?(name) && reload?
        if self.cache_hash[name]
          flush_cache(name)  # flush cached config values.
          fire_on_load(name) # force on_load triggers.
        end
      end
      changed
    end


    ##
    # This method provides shorthand to retrieve configuration data that
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
    # Ex.1  RConfig[:test_mode] =>
    #        RConfig.application[:test_mode] ||
    #        RConfig.application.test_mode
    #
    # Ex.2  RConfig[:web_app_root] => ENV['WEB_APP_ROOT']
    #
    # NOTE: The application config file can be in any of
    #       the supported formats (yml, xml, conf, etc.)
    #
    def [](key, file=:application)
      self.config_for(file)[key] || ENV[key.to_s.upcase]
    end

    ##
    # Get the value specified by the args, in the file specified by th name
    #
    def with_file(name, *args)
      logger.debug "with_file(#{name.inspect}, #{args.inspect})"
      result = args.inject(config_for(name)) { |v, i|
        logger.debug "v = #{v.inspect}, i = #{i.inspect}"
        case v
          when Hash
            v[i.to_s]
          when Array
            i.is_a?(Integer) ? v[i] : nil
          else
            nil
        end
      }
      logger.debug "with_file(#{name.inspect}, #{args.inspect}) => #{result.inspect}"
      result
    end

    ##
    # Get a hash of merged config data.
    # Will auto check every 5 minutes, for longer running apps, unless reload is disabled.
    #
    def config_for(name)
      name = name.to_s
      check_for_changes(name) if auto_check?(name)
      data = get_config_data(name)
      logger.debug "config_for(#{name.inspect}) => #{data.inspect}"
      data
    end

    ##
    # Short-hand access to config file by its name.
    #
    # Example:
    #
    #   RConfig.provider(:foo) => RConfig.with_file(:provider).foo
    #   RConfig.provider.foo   => RConfig.with_file(:provider).foo
    #
    def method_missing(method, * args)
      value = with_file(method, * args)
      logger.debug "#{self}.method_missing(#{method.inspect}, #{args.inspect}) => #{value.inspect}"
      value
    end

  end
end

