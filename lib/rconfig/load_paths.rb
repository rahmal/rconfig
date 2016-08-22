module RConfig
  module LoadPaths
    include Constants

    ##
    # Sets the list of directories to search for
    # configuration files.
    # The argument must be an array of strings representing
    # the paths to the directories, or a string representing
    # either a single path or a list of paths separated by
    # either a colon (:) or a semi-colon (;).
    def set_load_paths(paths)
      self.load_paths = parse_load_paths(paths)
      reload(true)  # Load Paths have changed so force a reload
    end

    ##
    # Adds the specified path to the list of directories to search for
    # configuration files.
    # It only allows one path to be entered at a time.
    def add_load_path(path)
      if path = parse_load_paths(path).first # only accept first one.
        self.load_paths << path
        self.load_paths.uniq!
        return reload(true)  # Load Paths have changed so force a reload
      end
      false
    end

    ##
    # If the paths are made up of a delimited string, then parse out the
    # individual paths. Verify that each path is valid.
    #
    # - If windows path separators are ';' and '!'
    # - otherwise the path separators are ';' and ':'
    #
    # This is necessary so windows paths can be correctly processed
    def parse_load_paths(paths)

      if paths.is_a? String
        path_separators = get_path_separators
        paths = paths.split(/#{path_separators}+/)
      end

      raise ArgumentError, "Path(s) must be a String or an Array [#{paths.inspect}]" unless paths.is_a? Array
      raise ArgumentError, "Must provide at least one load path: [#{paths.inspect}]" if paths.empty?

      paths.each do |dir|
        dir = CONFIG_ROOT if dir == 'CONFIG_ROOT'
        raise InvalidLoadPathError, "This directory is invalid: [#{dir.inspect}]" unless Dir.exists?(dir)
      end
      paths
    end

    ##
    # Indicates whether or not config_paths have been set.
    # Returns true if self.load_paths has at least one directory.
    def load_paths_set?
      not load_paths.blank?
    end


    private

    def get_path_separators
      is_windows = Gem.win_platform?
      if is_windows
        path_sep = (paths =~ /;/) ? ';' : '!'
      else
        path_sep = (paths =~ /;/) ? ';' : ':'
      end

      path_sep

    end

  end
end
