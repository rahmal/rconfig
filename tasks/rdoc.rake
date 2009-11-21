
namespace :rdoc do
  
  desc 'Remove rdocs'
  task :rm do
    sh "rm -rf doc"
  end

  desc 'Build rdocs'
  task :build => [:rm] do
    sh "rdoc -N lib -t RConfig --line-numbers --inline-source"
    sh "cp README.rdoc doc/README.rdoc"
    sh "rdoc -N -m README.rdoc"
  end
 
  desc 'Build docs, and open in browser for viewing (specify BROWSER)'
  task :open => [:rdoc] do
    browser = ENV["BROWSER"] || "firefox"
    sh "open #{browser} doc/index.html"
  end
  
end

