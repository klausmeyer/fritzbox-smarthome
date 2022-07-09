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

  it_behaves_like "a device with a simple on/off interface"

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
end
