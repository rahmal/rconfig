module RConfig
  class Options
    class << self
      attr_accessor :config_paths
      attr_accessor :suffixes
      attr_accessor :overlay
      attr_accessor :cache
      attr_accessor :cache_files
      attr_accessor :cache_hash
      attr_accessor :cache_config_files
      attr_accessor :last_auto_check
      attr_accessor :on_load
      attr_accessor :reload_cache
      attr_accessor :reload_interval
      attr_accessor :config_file_loaded
      attr_accessor :default_key

      attr_accessor :options

      def setup
        yield self
      end
    end

    self.config_paths = []
    self.suffixes     = {}
    self.overlay      = false
    self.cache        = {}
    self.cache_files  = {}
    self.cache_hash   = {}
    self.cache_config = {}
    self.last_auto_check = nil
    self.on_load      = {}
    self.reload_cache = false
    self.reload_interval = 300
    self.config_file_loaded = nil
    self.default_key  = [:default_key]

    self.options = {}

  end
end
