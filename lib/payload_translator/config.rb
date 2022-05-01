module PayloadTranslator
  class Config
    attr_reader :handlers, :formatters, :adapters_configurations
    def initialize
      @handlers = {}
      @formatters = {}
      @adapters_configurations = {}
    end

    def handlers=(value)
      @handlers.merge!(value)
    end

    def adapters_configurations=(value)
      @adapters_configurations.merge!(value)
    end

    def formatters=(value)
      @formatters.merge!(value)
    end
  end
end
