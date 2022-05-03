# require 'bundler/gem_tasks'

task :release do
  system 'gem build'
  system 'git diff --exit-code'
  system 'git add . && git c -m "Realse gem"'
  system 'gem push *.gem'
end
