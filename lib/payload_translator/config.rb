module PayloadTranslator
  class Config
    attr_reader :handlers, :formatters, :adapters
    def initialize
      @handlers = {}
      @formatters = {}
      @adapters = {}
    end

    def handlers=(value)
      @handlers.merge!(value)
    end

    def adapters=(value)
      @adapters.merge!(value)
    end

    def formatters=(value)
      @formatters.merge!(value)
    end
  end
end
