#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.dirname(__FILE__),"..","lib")

require 'rconfig'

dir = File.dirname(__FILE__)

puts "Current Dir: " + dir
puts "RConfig.add_config_path File.dirname(__FILE__) => #{RConfig.add_config_path(dir)}"
puts "RConfig.demo[:admin_email] => #{RConfig.demo[:admin_email]}"                  #=> 'root@localhost'
puts "RConfig.demo.listen_ip => #{RConfig.demo.listen_ip}"                          #=> '127.0.0.1'
puts "RConfig.demo[:group1][:group_name] => #{RConfig.demo[:group1][:group_name]}"  #=> 'daemons'
puts "RConfig.demo.group2.user_name => #{RConfig.demo.group2.user_name}"            #=> 'rita'
