require 'pry'
require 'payload_translator'
require 'yaml'
require 'json'

PayloadTranslator.configure do |config|
  config.formatters = {
    uppercase: ->(value) { value.upcase },
  }
  config.handlers = {
    get_name: ->(payload) { payload['name'] },
  }
end

describe PayloadTranslator::Service do
  let(:subject) { PayloadTranslator::Service.new(config) }
  let(:config) { YAML.load_file "./spec/fixtures/#{context}/config.yaml" }
  let(:input) { JSON.parse File.read("./spec/fixtures/#{context}/input.json")}

  context "with $map" do
    let(:context) { "with_map"}
    it '#translate' do
      expect(subject.translate(input)).to eq({"id"=>"1", "login_type"=>"APP", "user_name"=>"Jhon Doe"})
    end
  end

  context "with $fnc" do
    let(:context) { "with_fnc" }

    it '#translate' do
      expect(subject.translate(input)).to eq({"user_name"=>"Jhon Doe"})
    end
  end

  context "with depp object" do
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
end
