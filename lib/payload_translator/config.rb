module PayloadTranslator
  class Config
    attr_reader :handlers, :formatters
    def initialize
      @handlers = {}
      @formatters = {}
    end

    def handlers=(value)
      @handlers.merge!(value)
    end

    def formatters=(value)
      @formatters.merge!(value)
    end
  end
end
