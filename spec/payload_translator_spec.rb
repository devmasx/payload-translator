require 'payload_translator'
require 'yaml'
require 'json'

describe PayloadTranslator::Service do
  context "with $map" do
    let(:config) { YAML.load_file './spec/fixtures/with_map/config.yaml' }
    let(:input) { JSON.parse File.read('./spec/fixtures/with_map/input.json')}

    let(:subject) { PayloadTranslator::Service.new(config) }

    it 'translate' do
      expect(subject.translate(input)).to eq({"id"=>"1", "login_type"=>"APP", "user_name"=>"Jhon Doe"})
    end
  end
end
