require 'rdoc/task'

namespace :rdoc do
  RDoc::Task.new(:build) do |rdoc|
    rdoc.rdoc_dir = "doc"
    rdoc.main = "README.rdoc"
    rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    rdoc.options << "--all"
  end
end
