module PayloadTranslator
  class Service
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def translate(payload)
      config["payload"].each_with_object({}) do |(target_name, field_config), result|
        result[target_name] = FieldResolver.new(field_config).resolve(payload)
      end
    end
  end
end
