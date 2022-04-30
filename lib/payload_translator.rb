require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module PayloadTranslator
  VERSION = "0.0.1"
end
