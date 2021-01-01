require 'spec_helper'

RSpec.describe Fritzbox::Smarthome::Actor do
  before do
    stub_request(:get, 'https://fritz.box/login_sid.lua').
      to_return(body: '<SessionInfo><Challenge>1234567z</Challenge></SessionInfo>')

    stub_request(:get, 'https://fritz.box/login_sid.lua?response=1234567z-8d08321fe007cd28e2eae9f9051628db&username=smarthome').
      to_return(body: '<SessionInfo><SID>ff88e4d39354992f</SID></SessionInfo>')
  end

  describe '.all' do
    it 'returns a list of all actors' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))

      actors = described_class.all
      expect(actors.size).to eq 5

      actor = actors.shift
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '18'
      expect(actor.ain).to                    eq '12345 678901'
      expect(actor.name).to                   eq 'Heizung Wohnzimmer'
      expect(actor.manufacturer).to           eq 'AVM'
      expect(actor.group_members).to          be nil
    end
  end
end
