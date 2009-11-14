
Gem::Specification.new do |s|
  s.name = %q{rconfig}
  s.version = "0.0.1"
  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rahmal Conda"]
  s.date = %q{2009-11-13}
  s.default_executable = %q{rconfig}
  s.description = %q{The complete solution for Ruby Configuration Management}
  s.email = %q{rahmal@gmail.com}
  s.executables = ["rconfig"]
  s.extra_rdoc_files = []
  s.files = ["ChangeLog", "Manifest", "README", "Rakefile", "bin/rconfig", "rconfig.gemspec", "lib/rconfig.rb", "lib/rconfig/config_hash.rb", "lib/rconfig/config_parser.rb", "lib/rconfig/core_ext/hash.rb", "spec/runner_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/ui_spec.rb", "tasks/docs.rake", "tasks/gemspec.rake"]
  s.homepage = %q{http://www.rahmalconda.com/rconfig}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Commander", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rconfig}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{The complete solution for Ruby Configuration Management}
 
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
 
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>, [">= 1.5.0"])
    else
      s.add_dependency(%q<highline>, [">= 1.5.0"])
    end
  else
    s.add_dependency(%q<highline>, [">= 1.5.0"])
  end
end
 
