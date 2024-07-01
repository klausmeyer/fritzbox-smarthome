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
      expect(smoke_detector.attributes).to include(
        'type'          => :device,
        'id'            => '15',
        'ain'           => '12345 678903',
        'name'          => 'Rauchmelder Wohnzimmer',
        'manufacturer'  => '0x2c3c',
        'alert_state'   => 0,
        'group_members' => nil,
      )

      smoke_detector = smoke_detectors.shift
      expect(smoke_detector.attributes).to include(
        'type'          => :device,
        'id'            => '14',
        'ain'           => '12345 678904',
        'name'          => 'Rauchmelder Küche',
        'manufacturer'  => '0x2c3c',
        'alert_state'   => 0,
        'group_members' => nil,
      )
    end
  end
end
