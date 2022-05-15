require 'spec_helper'

RSpec.describe Fritzbox::Smarthome::Lightbulb do
  subject(:lightbulb) do
    described_class.new_from_api({ 'simpleonoff' => { 'state' => state } })
  end

  before do
    stub_request(:get, 'https://fritz.box/login_sid.lua').
      to_return(body: '<SessionInfo><Challenge>1234567z</Challenge></SessionInfo>')

    stub_request(:get, 'https://fritz.box/login_sid.lua?response=1234567z-8d08321fe007cd28e2eae9f9051628db&username=smarthome').
      to_return(body: '<SessionInfo><SID>ff88e4d39354992f</SID></SessionInfo>')
  end

  describe '.all' do
    it 'returns a list of lightbulbs' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))

      lightbulbs = described_class.all
      expect(lightbulbs.size).to eq 1

      lightbulb = lightbulbs.shift
      expect(lightbulb.type).to                   eq :device
      expect(lightbulb.id).to                     eq '406'
      expect(lightbulb.ain).to                    eq '11111 2233445'
      expect(lightbulb.name).to                   eq 'Flurlampe'
      expect(lightbulb.manufacturer).to           eq 'AVM'
    end
  end

  describe '#active?' do
    subject { lightbulb.active? }

    context 'when simpleonoff_state is "0"' do
      let(:state) { '0' }
      it { is_expected.to be false }
    end

    context 'when simpleonoff_state is "1"' do
      let(:state) { '1' }
      it { is_expected.to be true }
    end
  end

  describe '#toggle!' do
    before { stub_request(:get, api_cmd_url).to_return(status: 200) }

    let(:api_cmd_url) do
      "https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=setsimpleonoff&#{lightbulb.ain}&onoff=#{onoff}"
    end

    context 'when the lightbulb is off' do
      let(:state) { "0" }
      let(:onoff) { "1" }

      it "switches the lightbulb on" do
        expect { lightbulb.toggle! }
          .to change { lightbulb.active? }
          .from(false).to(true)

        expect(a_request(:get, api_cmd_url)).to have_been_made.once
      end
    end

    context 'when the lightbulb is on' do
      let(:state) { "1" }
      let(:onoff) { "0" }

      it "switches the lightbulb off" do
        expect { lightbulb.toggle! }
          .to change { lightbulb.active? }
          .from(true).to(false)

        expect(a_request(:get, api_cmd_url)).to have_been_made.once
      end
    end
  end
end
