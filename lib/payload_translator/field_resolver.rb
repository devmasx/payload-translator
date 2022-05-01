module PayloadTranslator
  class FieldResolver
    attr_reader :config, :handlers, :formatters, :configuration, :payload

    def initialize(field_config, configuration)
      @configuration = configuration
      @handlers = configuration.handlers
      @formatters = configuration.formatters
      @config = field_config
    end

    def resolve(payload)
      @payload = payload
      if deep_object?
        resolve_deep_object
      elsif config["$fnc"]
        resolve_fnc
      elsif config["$map"]
        resolve_map
      else
        resolve_value
      end
    end

    private

    def resolve_value
      with_formatter do
        search_value(fetch_field)
      end
    end

    def resolve_fnc
      config["$fnc"]
      handler = handlers.fetch(config["$fnc"].to_sym)
      handler.call(payload)
    end

    def resolve_map
      value = search_value(fetch_field)
      return config["$default"] unless value
      if config["$map_formatter"]
        fotmatter = formatters.fetch(config["$map_formatter"].to_sym)
        value = fotmatter.call(value)
      end

      config["$map"].fetch(value) { config["$map_default"] }
    end

    def resolve_deep_object
      config.each_with_object({}) do |(target_name, field_config), result|
        result[target_name] = FieldResolver.new(field_config, configuration).resolve(payload)
      end
    end

    def search_value(field_or_fields)
      if field_or_fields.is_a?(Array)
        field = field_or_fields.find { |field| payload[field] }
        payload[field]
      else
        payload[field_or_fields]
      end
    end

    def with_formatter
      return yield unless config["$formatter"]
      formatter = formatters.fetch(config["$formatter"].to_sym)
      formatter.call(yield)
    end

    def fetch_field
      config.fetch("$field") do
        hander = handlers.fetch(config.fetch("$field_fnc").to_sym)
        hander.call(payload)
      end
    end

    def deep_object?
      !config.keys.any? {|key| key =~ /\$/ }
    end
  end
end
