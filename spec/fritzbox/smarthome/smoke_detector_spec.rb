require 'spec_helper'

RSpec.describe Fritzbox::Smarthome::SmokeDetector do
  before do
    stub_request(:get, 'https://fritz.box/login_sid.lua').
      to_return(body: '<SessionInfo><Challenge>1234567z</Challenge></SessionInfo>')

    stub_request(:get, 'https://fritz.box/login_sid.lua?response=1234567z-8d08321fe007cd28e2eae9f9051628db&username=smarthome').
      to_return(body: '<SessionInfo><SID>ff88e4d39354992f</SID></SessionInfo>')
  end

  describe '.all' do
    it 'returns a list of smoke detectors' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))

      smoke_detectors = described_class.all
      expect(smoke_detectors.size).to eq 2

      smoke_detector = smoke_detectors.shift
      expect(smoke_detector.type).to                   eq :device
      expect(smoke_detector.id).to                     eq '15'
      expect(smoke_detector.ain).to                    eq '12345 678903'
      expect(smoke_detector.name).to                   eq 'Rauchmelder Wohnzimmer'
      expect(smoke_detector.manufacturer).to           eq '0x2c3c'
      expect(smoke_detector.alert_state).to            eq 0
      expect(smoke_detector.group_members).to          be nil

      smoke_detector = smoke_detectors.shift
      expect(smoke_detector.type).to                   eq :device
      expect(smoke_detector.id).to                     eq '14'
      expect(smoke_detector.ain).to                    eq '12345 678904'
      expect(smoke_detector.name).to                   eq 'Rauchmelder Küche'
      expect(smoke_detector.manufacturer).to           eq '0x2c3c'
      expect(smoke_detector.alert_state).to            eq 0
      expect(smoke_detector.group_members).to          be nil
    end
  end
end
