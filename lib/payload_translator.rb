require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module PayloadTranslator
  class Config
    def initialize
      @handlers = {}
    end

    def handlers
      @handlers
    end

    def handlers=(value)
      @handlers.merge!(value)
    end
  end

  def self.configure
    @@config ||= Config.new
    yield(@@config)
    @@config
  end

  VERSION = "0.0.1"
end
