# require 'bundler/gem_tasks'

task :release do
  system 'gem build payload_translator.gemspec'
  system 'gem push *.gem'
end
