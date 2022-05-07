module PayloadTranslator
  class Payload
    def self.fetch_field(payload, field_or_fields)
      return field_or_fields unless field_or_fields.is_a?(Array)

      field_or_fields.find { |field| search_value(payload, field) }
    end

    def self.search_value(payload, field, default = nil)
      field = fetch_field(payload, field)
      return payload.dig(*field.split(".")) if field =~ /\./

      payload.fetch(field, default)
    end
  end
end
