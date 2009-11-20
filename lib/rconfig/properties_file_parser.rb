
#++
# Copyright (c) 2009 Rahmal Conda <rahmal@gmail.com>
#
# This class parses key/value based properties files used for configuration.
# It is used by rconfig to import configuration files of the aforementioned
# format. Unlike yaml, and xml files it can only support two levels. First,
# it can have root level properties.
#
# Example:
#            server_url=host.domain.com
#            server_port=8080
#
# Secondly, it can have properties grouped into catagories. The group names
# must be specified within brackets like [ ... ]
#
# Example:
#            [server]
#            url=host.domain.com
#            port=8080
#
#--
class PropertiesFileParser
  include Singleton # Don't instantiate this class
 
  ##
  # Parse config file and import data into hash to be stored in config.
  #
  def self.parse config_file
    validate(config_file)

    config = {}

    # The config is top down.. anything after a [group] gets added as part
    # of that group until a new [group] is found.  
    group = nil
    config_file.each do |line|     # for each line in the config file
      line.strip!
      unless (/^\#/.match(line))   # skip comments (lines that state with '#')
        if(/\s*=\s*/.match(line))  # if this line is a config property
          key, val = line.split(/\s*=\s*/, 2)  # parse key and value from line
          key = key.chomp.strip
          val = val.chomp.strip
          if (val)
            if val =~ /^['"](.*)['"]$/  # if the value is in quotes
              value = $1                # strip out value from quotes
            else
              value = val               # otherwise, leave as-is
            end
          else
            value = ''                  # if value was nil, set it to empty string
          end 

          if group                      # if this property is part of a group
            config[group][key] = value  # then add it to the group
          else                   
            config[key] = value         # otherwise, add it to top-level config
          end
         
        # Group lines are parsed into arrays: %w('[', 'group', ']')
        elsif(/^\[(.+)\]$/.match(line).to_a != [])  # if this line is a config group
          group = /^\[(.+)\]$/.match(line).to_a[1]  # parse the group name from line
          config[group] ||= {}                      # add group to top-level config
        end
      end
    end 
    config  # return config hash
  end       # def parse

  ##
  # Validate the config file. Check that the file exists and that it's readable.
  # TODO: Create real error.
  #
  def self.validate config_file
    raise 'Invalid config file name.' unless config_file
    raise Errno::ENOENT, "#{config_file} does not exist" unless File.exist?(config_file.path)
    raise Errno::EACCES, "#{config_file} is not readable" unless File.readable?(config_file.path)
  end  

end # class PropertiesFileParser
