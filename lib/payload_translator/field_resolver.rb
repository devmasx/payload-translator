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
      if is_a_array?
        resolve_array
      elsif deep_object?
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
      call_fnc(config.fetch("$fnc"))
    end

    def resolve_map
      value = search_value(fetch_field)
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

    def resolve_array
      [].tap do |result|
        config.each_with_index do |field_config, index|
          result[index] = FieldResolver.new(field_config, configuration).resolve(payload)
        end
      end
    end

    def search_value(field_or_fields)
      Payload.search_value(payload, field_or_fields, config["$default"])
    end

    def with_formatter
      return yield unless config["$formatter"]
      formatter = formatters.fetch(config["$formatter"].to_sym)
      formatter.call(yield)
    end

    def fetch_field
      config.fetch("$field") do
        call_fnc(config.fetch("$field_fnc"))
      end
    end

    def call_fnc(name)
      handler = handlers.fetch(name.to_sym)
      case handler.arity
      when 0
        handler.call
      when 1
        handler.call(payload)
      when 2
        handler.call(payload, config)
      end
    end

    def is_a_array?
      config.is_a?(Array)
    end

    def deep_object?
      !config.keys.any? {|key| key =~ /\$/ }
    end
  end
end
