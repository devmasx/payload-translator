# frozen_string_literal: true

require File.expand_path('lib/payload_translator', __dir__)
Gem::Specification.new do |s|
  s.name        = 'payload-translator'
  s.version     = PayloadTranslator::VERSION
  s.date        = '2022-04-02'
  s.summary     = 'PayloadTranslator'
  s.description = 'Use configuration to transform a payload to another payload'
  s.authors     = ['Miguel Savignano']
  s.email       = 'migue.masx@gmail.com'
  s.files       = Dir.glob('{lib}/**/{*,.?*}') + %w[LICENSE README.md]
  s.homepage    = 'https://github.com/devmasx/payload-translator'
  s.license     = 'MIT'
  s.require_paths = ['lib']
  s.add_runtime_dependency 'zeitwerk'
end
