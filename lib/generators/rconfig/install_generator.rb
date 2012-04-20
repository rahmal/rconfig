module RConfig
  module Generators
    class InstallGenerator < Rails::Generators::Base
      namespace 'rconfig:install'
      source_root File.expand_path('../templates', __FILE__)
      desc 'Create RConfig settings initializer file'

      def copy_initializer
        template 'rconfig.rb', 'config/initializers/rconfig.rb'
      end
    end
  end
end

