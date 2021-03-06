require 'pry'
require 'payload_translator'
require 'yaml'
require 'json'

PayloadTranslator.configure do |config|
  config.adapters_configurations = {
    internal_to_external: {
      "payload" => {
        "id" => { "$field" => "_id" }
      }
    },
    external_to_internal: {
      "payload" => {
        "_id" => { "$field" => "id" }
      }
    }
  }
  config.formatters = {
    uppercase: ->(value) { value.upcase },
  }
  config.handlers = {
    get_name: ->(payload, field_config) { payload['name'] },
    fetch_id: ->() { '_id' }
  }
end

describe PayloadTranslator::Service do
  let(:subject) { PayloadTranslator::Service.new(config) }
  let(:config) { YAML.load_file "./spec/fixtures/#{context}/config.yaml" }
  let(:input) { JSON.parse File.read("./spec/fixtures/#{context}/input.json")}

  context "load adapters" do
    it '#translate to external' do
      translator = PayloadTranslator::Service.new(:internal_to_external)
      expect(translator.translate({"_id" => "1234" })).to eq({"id"=>"1234"})
    end

    it '#translate to internal' do
      translator = PayloadTranslator::Service.new(:external_to_internal)
      expect(translator.translate({"id" => "1234" })).to eq({"_id"=>"1234"})
    end
  end

  context "with $map" do
    let(:context) { "with_map"}
    it '#translate' do
      expect(subject.translate(input)).to eq({"id"=>"1", "login_type"=>"APP", "user_name"=>"Jhon Doe", "country" => "US", "_type" => "User"})
    end

    it '#translate with empty key' do
      expect(subject.translate(input.merge({ "login_provider" => "" }))).to eq({"id"=>"1", "login_type"=>"UNKNOWN", "user_name"=>"Jhon Doe", "country" => "US", "_type" => "User"})
    end
  end

  context "with $fnc" do
    let(:context) { "with_fnc" }

    it '#translate' do
      expect(subject.translate(input)).to eq({"user_name"=>"Jhon Doe","id" => "1"})
    end
  end

  context "with $field_fnc" do
    let(:context) { "with_fnc" }

    it '#translate' do
      expect(subject.translate(input)).to eq({"user_name"=>"Jhon Doe","id" => "1"})
    end
  end

  context "with multi field" do
    let(:context) { "with_multi_field" }

    it '#translate' do
      expect(subject.translate(input)).to eq({"id" => "1", "user_id" => "1"})
    end
  end

  context "with deep object" do
    let(:context) { "with_deep_object" }

    it '#translate' do
      expect(subject.translate(input)).to eq({"user" => {"login"=>{"type"=>"APP"}, "name"=>"Jhon Doe"}})
    end
  end

  context "with map formatter" do
    let(:context) { "with_map_formatter" }
    let(:subject) {
      formatters = { to_integer: ->(value) { value.to_i } }
      PayloadTranslator::Service.new(config, formatters: formatters)
    }

    it '#translate' do
      expect(subject.translate(input)).to eq("login_type" => "APP", "id" => 1)
    end
  end

  context "with multiple translations" do
    it '#translate multiple' do
      translator = PayloadTranslator::ServiceMultiple.new([:internal_to_external, :external_to_internal])
      translated_output = translator.translate({"_id" => "1"}) do |translated_input|
        expect(translated_input).to eq({"id"=>"1"})
        translated_input
      end
      expect(translated_output).to eq({"_id"=>"1"})
    end
  end

  context "with array" do
    let(:context) { "with_array"}
    it '#translate' do
      expect(subject.translate(input)).to(
        eq({
          "addresses" => [{"city"=>"City", "state"=>"State", "type"=>"shipping"}],
          "countries" => [{"name" => "US"}, {"name" => "AU"}]
        })
      )
    end

    it '#translate with error' do
      expect{ subject.translate(input.merge({"countries" => "STRING"}))}.to raise_error(
        PayloadTranslator::ArrayFieldError
      )
    end
  end
end
