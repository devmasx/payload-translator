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
  "_id": "1",
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
