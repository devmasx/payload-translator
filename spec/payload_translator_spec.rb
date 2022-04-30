require 'payload_translator'
require 'yaml'
require 'json'

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

    let(:subject) {
      PayloadTranslator.configure do |config|
        config.handlers = {
          get_name: ->(payload) { payload['name'] }
        }
      end
      PayloadTranslator::Service.new(config)
    }

    it '#translate' do
       expect(subject.translate(input)).to eq({"user_name"=>"Jhon Doe"})
    end
  end

  context "with depp object" do
    let(:context) { "with_deep_object" }

    let(:subject) {
      PayloadTranslator.configure do |config|
        config.handlers = {
          get_name: ->(payload) { payload['name'] }
        }
      end
      PayloadTranslator::Service.new(config)
    }

    it '#translate' do
       expect(subject.translate(input)).to eq({"user" => {"login"=>{"type"=>"APP"}, "name"=>"Jhon Doe"}})
    end
  end
end
