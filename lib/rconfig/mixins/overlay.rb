module Mixins
  module Overlay

    # Specifies an additional overlay suffix.
    #
    # E.g. 'gb' for UK locale.
    #
    # Defaults from ENV['CONFIG_OVERLAY'].
    def self.overlay
      @@overlay ||= (x = ENV['CONFIG_OVERLAY']) && x.dup.freeze
    end


    ##
    # Sets overlay for 
    def self.overlay=(x)
      flush_cache if @@overlay != x
      @@overlay = x && x.dup.freeze
    end


    ##
    # Returns a list of suffixes to try for a given config name.
    #
    # A config name with an explicit overlay (e.g.: 'name_GB')
    # overrides any current _overlay.
    #
    # This allows code to specifically ask for config overlays
    # for a particular locale.
    #
    def self.suffixes(name)
      name = name.to_s
      @@suffixes[name] ||=
          begin
            ol = overlay
            name_x = name.dup
            if name_x.sub!(/_([A-Z]+)$/, '')
              ol = $1
            end
            name_x.freeze
            result = if ol
              ol_ = ol.upcase
              ol = ol.downcase
              x = []
              SUFFIXES.each do |suffix|
                # Standard, no overlay:
                # e.g.: database_<suffix>.yml
                x << suffix

                # Overlay:
                # e.g.: database_(US|GB)_<suffix>.yml
                x << [ol_, suffix]
              end
              [name_x, x.freeze]
            else
              [name.dup.freeze, SUFFIXES.freeze]
            end
            result.freeze

            logger.debug { "suffixes(#{name}) => #{result.inspect}" }

            result
          end
    end

  end
end
