module RConfig
  class Logger #:nodoc:
    attr_accessor :level, :log_format, :date_format
    attr_reader   :output

    FATAL     = 4
    ERROR     = 3
    WARN      = 2
    INFO      = 1
    DEBUG     = 0
    
    MAX_LEVEL = 4

    def initialize(options={})
      # Use provided output
      if output = options[:output] && output.respond_to?(:puts)
        @output = output
        @needs_close = false
      end

      # Use log file
      if output.nil? && options[:file] && File.exists?(optios[:file])
        @output = File.open(options[:file].to_s, 'a')
        @needs_close = true
      end

      # Default to stderr, if no outputter or file provider
      @output ||= STDERR

      # Use provided level or default to warn
      @level = options[:level] ||
        ((defined?(Rails) && %w[test development].include?(Rails.env)) ? DEBUG : WARN)

      # Date format
      @date_format = options[:date_format] || '%Y-%m-%d %H:%M:%S'
      #@log_format  = options[:log_format] || "[%l] %d :: %M :: %t"
    end

    def close
      output.close if @needs_close
    end

    def log(level, message)
      if self.level <= level
        indent = "%*s" % [MAX_LEVEL, "*" * (MAX_LEVEL - level)]
        message.lines.each do |line|
          log_str = "[#{indent}] #{Time.now.strftime(self.date_format)} :: #{line.strip}\n"
          output.puts log_str
        end
      end
    end

    def fatal(message)
      log(FATAL, message)
    end

    def error(message)
      log(ERROR, message)
    end

    def warn(message)
      log(WARN, message)
    end

    def info(message)
      log(INFO, message)
    end

    def debug(message)
      log(DEBUG, message)
    end

  end

  class DisabledLogger
    def log(level, message) end
    def dont_log(message) end

    alias_method :fatal, :dont_log
    alias_method :error, :dont_log
    alias_method :warn,  :dont_log
    alias_method :info,  :dont_log
    alias_method :debug, :dont_log
  end
end

