module RConfig
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Create RConfig settings initializer file"
      source_root File.expand_path("../templates", __FILE__)

      def create_initializer_file
        template "rconfig.rb", "config/initializers/rconfig.rb"
      end
    end
  end
end

