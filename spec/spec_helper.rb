
root_dir = File.expand_path(File.dirname(__FILE__))
conf_dir = File.join(root_dir, 'test', 'config_files')

ENV['TIER'] = 'development'
ENV['CONFIG_PATH'] = conf_dir

# Loads the rconfig library
$LOAD_PATH << File.join(root_dir,'..','lib')

# Requires supporting files in ./support/ and its subdirectories.
Dir["#{root_dir}/support/**/*.rb"].each {|f| require f}

