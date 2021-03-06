## Payload translator

Using a yaml configuration you can transform a payload to another payload.
Example:

```yaml
# config.yaml
payload:
  id:
    $field: _id
    $formatter: to_integer
  user_name:
    $field: name
  login_type:
    $field: login_provider
    $map:
      google: GOOGLE
      twitter: TWITTER
      auth0: APP
  country:
    $fnc: get_country
```

Input:

```json
// internal_payload.json

{
  "_id": 1,
  "name": "Jhon Doe",
  "login_provider": "auth0"
}
```

```ruby
translator = PayloadTranslator::Service.new(config)
external_payload = translator.translate(internal_payload)
```

Return:

```json
// external_payload.json

{
  "id": "1",
  "user_name": "Jhon Doe",
  "login_type": "APP"
}
```

## Configure handlers

Resolve the field output with a custom function.

```ruby
PayloadTranslator.configure do |config|
  config.handlers = {
    get_country: ->(payload) { payload['name'] },
  }
end
```

Or per service

```ruby
PayloadTranslator::Service(config, handlers: get_country: ->(payload) { payload['name'] })
```

## Configure formatters

Apply different formatters to the output.

```ruby
PayloadTranslator.configure do |config|
  config.formatters = {
    uppercase: ->(value) { value.upcase },
    to_integer: ->(value) { value.to_i },
  }
end
```

Or formatter per service

```ruby
PayloadTranslator::Service(config, formatters: to_integer: ->(value) { value.to_i })
```

## Configure adapters configuration

Store adapter configuration

```ruby
PayloadTranslator.configure do |config|
  config.adapters_configurations = {
    internal_to_external: {
      "payload" => {
        "id" => { "$field" => "_id" }
      }
    }
  }
end
```

```ruby
translator = PayloadTranslator::Service.new(:internal_to_external)
```

### Multiple translator

```ruby
translator = PayloadTranslator::ServiceMultiple.new([:internal_to_external, :external_to_internal])

translated_response = translator.translate({"user_id" => 4 }) do |translated_payload|
  response = Net::HTTP.post_form(
    URI("https://jsonplaceholder.typicode.com/todos"),
    translated_payload
  ).body

  JSON.parse(response)
end
```

### Complex adapters

Translate all array items, use `$field_for_all_items` special propery of the first elemtn of the array to apply the same translation from the same field
Config:

```yaml
payload:
  countries:
    - $field_for_all_items: countries
      name:
        $field: 'name'
```

Input:

```json
{
  "countries": [
    {
      "name": "US",
      "code": "US_CODE"
    },
    {
      "name": "AU",
      "code": "AU_CODE"
    }
  ]
}
```

Result:

```json
{
  "countries": [
    {
      "name": "US"
    },
    {
      "name": "AU"
    }
  ]
}
```
