require 'logger'

##
# Creates a logger for small apps or gems that may not be using log4r.
# I created this to encapsulate all of the logging code in my smaller 
# projects so thay I don't clutter them up with utility code.
#
module DefaultLogger

 module MacroMethods
  
    def create_logger options = {}
      class_inheritable_accessor :default_logger

      logger = Logger.new options[:file] ? options[:file] : STDOUT
      logger.level = options[:level] ? options[:level] :  Logger::WARN       
      logger.datetime_format = options[:format] ? options[:format] : "%Y-%m-%d %H:%M:%S"
      logger.progname = options[:app_name] ? options[:app_name] : nil
      
      self.default_logger = logger
            
      include DefaultLogger::InstanceMethods
      extend  DefaultLogger::ClassMethods  
    end
  end
  
  module ClassMethods
    def logger
      self.default_logger
    end
  end
  
  module InstanceMethods
     def logger
       self.class.logger
     end
  end
  
end
Object.class_eval { extend DefaultLogger::MacroMethods }

