# require 'bundler/gem_tasks'

task :release do
  system 'gem build'
  system 'git diff --exit-code'
  system 'gem push *.gem'
end
