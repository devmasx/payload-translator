module PayloadTranslator
  class Service
    attr_reader :adapt_config, :configuration

    def initialize(adapt_config, handlers: {}, formatters: {})
      @adapt_config = adapt_config
      @configuration = merge_configuration(handlers: handlers, formatters: formatters)
    end

    def merge_configuration(handlers: , formatters:)
      PayloadTranslator::Config.new.tap do |config|
        config.handlers = PayloadTranslator.configuration.handlers.merge(handlers)
        config.formatters = PayloadTranslator.configuration.formatters.merge(formatters)
      end
    end

    def translate(payload)
      adapt_config["payload"].each_with_object({}) do |(target_name, field_config), result|
        result[target_name] = FieldResolver.new(field_config, configuration).resolve(payload)
      end
    end
  end
end
