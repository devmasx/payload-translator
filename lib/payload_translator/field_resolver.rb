class PayloadTranslator::FieldResolver
  attr_reader :config
  def initialize(field_config)
    @config = field_config
  end

  def resolve(payload)
    if deep_object?
      resolve_deep_object(payload)
    elsif config["$map"]
      resolve_map(payload)
    else
      resolve_value(payload)
    end
  end

  def resolve_value(payload)
    payload[config["$field"]]
  end

  def resolve_map(payload)
    value = payload[config["$field"]]
    return config["$default"] unless value

    config["$map"].fetch(value) { config["$map_default"] }
  end

  def resolve_deep_object(payload)
    config.each_with_object({}) do |(target_name, field_config), result|
      result[target_name] = FieldResolver.new(field_config).resolve(payload)
    end
  end

  def deep_object?
    !config.keys.any? {|key| key =~ /\$/ }
  end
end
