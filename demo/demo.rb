#!/usr/bin/env ruby

require('rubygems')
require('rconfig')
#require('./lib/parseconfig.rb')

begin
	c = ParseConfig.new('demo.conf')
rescue Errno::ENOENT 
	puts "The config file you specified was not found"
	exit
rescue Errno::EACCES 
	puts "The config file you specified is not readable"
	exit
end

puts
puts 'Reading main config section and groups...'
puts '-' * 77
puts 
c.write()
puts
puts 'Available params are...'
puts '-' * 77
puts 
puts c.get_params()
puts
puts

puts 'Available sub-groups are...'
puts '-' * 77
puts 
puts c.get_groups()
puts
puts

puts 'Accessing sub-group params...'
puts '-' * 77
puts 
puts "group1 user name value is: #{c.params['group1']['user_name']}"
puts
puts

puts "Using params hash..."
puts '-' * 77
puts
puts "The admin email address is #{c.params['admin_email']}"
puts 
puts

puts "Using get_value (kind of deprecated)..."
puts '-' * 77
puts
puts "The listen address is #{c.get_value('listen_ip')} and the user name " + 
     "is #{c.get_value('group1')['user_name']}"
puts 
puts

puts "Writing the config out to a file"
puts '-' * 77
puts
f = open('/tmp/parseconfig_sample_config', 'w')
c.write(f)
f.close()
puts "Config written to /tmp/parseconfig_sample_config"
puts
