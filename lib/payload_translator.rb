require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module PayloadTranslator
  def self.configuration
    @@config ||= Config.new
  end

  def self.configure
    yield(configuration)
    configuration
  end

  VERSION = "0.0.1"
end
