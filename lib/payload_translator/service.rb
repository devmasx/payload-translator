module PayloadTranslator
  class Service
    attr_reader :adapt_config, :configuration

    def initialize(adapter_config_or_name, handlers: {}, formatters: {})
      @configuration = merge_configuration(handlers: handlers, formatters: formatters)
      @adapt_config = fetch_adapter_config(adapter_config_or_name)
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

    private

    def fetch_adapter_config(adapter_config_or_name)
      return adapter_config_or_name if adapter_config_or_name.is_a?(Hash)

      PayloadTranslator.configuration.adapters_configurations.fetch(adapter_config_or_name)
    end
  end
end
