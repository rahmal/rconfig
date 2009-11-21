require 'rake'

Gem::Specification.new do |s|
  s.name = "rconfig"
  s.version = "0.3"
  s.date = "2009-11-20"
  s.rubyforge_project = "rconda-rconfig"

  s.author = "Rahmal Conda"
  s.email = "rahmal@gmail.com"
  s.homepage = "http://www.rahmalconda.com"

  s.description = "The complete solution for Ruby Configuration Management"
  s.summary = "RConfig manages configuration within Ruby applications. " +
              "It supports yaml, xml, and properties files, with hash " +
              "based and dot notation access, while providing an elegant API."

  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = "1.3.5"
  s.require_paths = ["lib", "tasks"]
  s.add_dependency("activesupport", ">= 2.2.2")

  s.files = FileList["{lib}/**/*"].to_a
  s.test_files = FileList["{test}/**/*test.rb"].to_a
 
 # s.files = ["ChangeLog", "demo/", "demo/demo.conf", "demo/demo.rb", "demo/demo.xml", "demo/demo.yml", "demo/global.yml", "lib/", "lib/rconfig/", "lib/rconfig/config_hash.rb", "lib/rconfig/config_parser.rb", "lib/rconfig/core_ext/", "lib/rconfig/core_ext/hash.rb", "rconfig.rb", "LICENSE", "Manifest", "Rakefile", "rconfig.gemspec", "README", "tasks/", "tasks/docs.rake", "tasks/gemspec.rake", "test/", "test/rconfig_test.rb", "test/test_files/", "test/test_files/global.yml", "test/test_files/test_development.yml", "test/test_files/test_local.yml", "test/test_files/test_production.yml", "test/test_files/test.yml"]

  s.test_files = FileList["test/rconfig_test.rb", "test"].to_a

  s.has_rdoc = true 
  s.extra_rdoc_files = []
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "RConfig", "--main", "README.rdoc"]

end
