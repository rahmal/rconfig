
namespace :gem do

  desc 'Clean-up old gem version(s).'
  task :clean do
    sh "rm -f *.gem"
  end

  desc 'Build gem'
  task :build => [:clean] do
    sh "gem build rconfig.gemspec"
  end
end

