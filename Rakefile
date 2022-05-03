require 'bundler/gem_tasks'

task :release do
  system 'rake build'
  system 'git diff --exit-code'
  # system 'gem push *.gem'
end
