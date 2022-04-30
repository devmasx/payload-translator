require 'payload_translator'
require 'yaml'
require 'json'

describe PayloadTranslator::Service do
  let(:subject) { PayloadTranslator::Service.new(config) }

  let(:config) { YAML.load_file './spec/fixtures/with_map/config.yaml' }
  let(:input) { JSON.parse File.read('./spec/fixtures/with_map/input.json')}

  context "with $map" do
    it '#translate' do
      expect(subject.translate(input)).to eq({"id"=>"1", "login_type"=>"APP", "user_name"=>"Jhon Doe"})
    end
  end

  context "with $fnc" do
    let(:config) { YAML.load_file './spec/fixtures/with_fnc/config.yaml' }
    let(:input) { JSON.parse File.read('./spec/fixtures/with_fnc/input.json')}

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
end
