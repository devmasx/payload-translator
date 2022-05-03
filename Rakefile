require 'bundler/gem_tasks'

task :release do
  system 'rake build'
  system 'gem push *.gem'
  system 'git diff --exit-code'
end
