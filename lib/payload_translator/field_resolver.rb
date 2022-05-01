module PayloadTranslator
  class FieldResolver
    attr_reader :config, :handlers, :formatters, :configuration

    def initialize(field_config, configuration)
      @configuration = configuration
      @handlers = configuration.handlers
      @formatters = configuration.formatters
      @config = field_config
    end

    def resolve(payload)
      if deep_object?
        resolve_deep_object(payload)
      elsif config["$fnc"]
        resolve_fnc(payload)
      elsif config["$map"]
        resolve_map(payload)
      else
        resolve_value(payload)
      end
    end

    def resolve_value(payload)
      with_formatter do
        payload[config["$field"]]
      end
    end

    def with_formatter
      return yield unless config["$formatter"]
      formatter = formatters.fetch(config["$formatter"].to_sym)
      formatter.call(yield)
    end

    def resolve_fnc(payload)
      config["$fnc"]
      handler = handlers.fetch(config["$fnc"].to_sym)
      handler.call(payload)
    end

    def resolve_map(payload)
      value = payload[config["$field"]]
      return config["$default"] unless value
      if config["$map_formatter"]
        fotmatter = formatters.fetch(config["$map_formatter"].to_sym)
        value = fotmatter.call(value)
      end

      config["$map"].fetch(value) { config["$map_default"] }
    end

    def resolve_deep_object(payload)
      config.each_with_object({}) do |(target_name, field_config), result|
        result[target_name] = FieldResolver.new(field_config, configuration).resolve(payload)
      end
    end

    def deep_object?
      !config.keys.any? {|key| key =~ /\$/ }
    end
  end
end
