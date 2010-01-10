require 'rake'

Gem::Specification.new do |s|
  s.name = "rconfig"
  s.version = File.read('VERSION').strip
  s.date = Date.today
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
  s.test_files = FileList["{spec}/**/*", "{test}/**/*", "{demo}/**/*"].to_a

  s.has_rdoc = true 
  s.extra_rdoc_files = FileList["{doc}/**/*", "README.rdoc"].to_a
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "RConfig", "--main", "README.rdoc"]

end
