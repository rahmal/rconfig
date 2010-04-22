require 'logger'

##
# Creates a logger for small apps or gems that may not be using log4r.
# I created this to encapsulate all of the logging code in my smaller 
# projects so thay I don't clutter them up with utility code.
#
module DefaultLogger

 module ClassMethods
  
    def create_logger options = {}
      class_inheritable_accessor :default_logger, :options

      self.options = options || {}

      logger = Logger.new( check_options(:file, STDOUT) )
      logger.level = check_options(:level,  ENV['LOG_LEVEL'] || Logger::INFO)
      logger.datetime_format = check_options(:format, "%Y-%m-%d %H:%M:%S")
      logger.progname = check_options(:app_name, 'RConfig')
      
      self.default_logger = logger
            
      include DefaultLogger::InstanceMethods
    end

    def logger
      self.default_logger
    end

    def check_options key, default_value=nil
      puts "Key: #{key.inspect}, Value: #{self.options[key]}, Default: #{default_value}"
      self.options[key].nil? ? default_value : self.options[key]
    end

  end
  
  module InstanceMethods
     def logger
       self.class.logger
     end
  end
  
end
Object.class_eval { extend DefaultLogger::ClassMethods }

