
namespace :gem do
  desc 'Build gem'
  task :build do
    sh "gem build rconfig.gemspec"
  end
end

