module PayloadTranslator
  class ServiceMultiple < Service
    attr_reader :translators
    def initialize(adapter_configs_or_names, handlers: {}, formatters: {})
      @translators = adapter_configs_or_names.map do |adapter_config_or_name|
        Service.new(adapter_config_or_name, handlers: handlers, formatters: formatters)
      end
    end

    def translate(payload, &block)
      tranlated_payload = translators[0].translate(payload)
      translators[1].translate(yield(tranlated_payload))
    end
  end
end



