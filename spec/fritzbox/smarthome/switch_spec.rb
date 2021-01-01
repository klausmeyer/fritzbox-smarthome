require 'spec_helper'

RSpec.describe Fritzbox::Smarthome::Switch do
  before do
    stub_request(:get, 'https://fritz.box/login_sid.lua').
      to_return(body: '<SessionInfo><Challenge>1234567z</Challenge></SessionInfo>')

    stub_request(:get, 'https://fritz.box/login_sid.lua?response=1234567z-8d08321fe007cd28e2eae9f9051628db&username=smarthome').
      to_return(body: '<SessionInfo><SID>ff88e4d39354992f</SID></SessionInfo>')
  end

  describe '.all' do
    it 'returns a list of switches' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))

      smoke_detectors = described_class.all
      expect(smoke_detectors.size).to eq 1

      smoke_detector = smoke_detectors.shift
      expect(smoke_detector.type).to                   eq :device
      expect(smoke_detector.id).to                     eq '18'
      expect(smoke_detector.ain).to                    eq '12345 678905'
      expect(smoke_detector.name).to                   eq 'FRITZ!DECT 200 Steckdose'
      expect(smoke_detector.manufacturer).to           eq 'AVM'
      expect(smoke_detector.switch_state).to           eq 0
      expect(smoke_detector.switch_mode).to            eq 'manuell'
      expect(smoke_detector.switch_lock).to            eq 0
      expect(smoke_detector.switch_devicelock).to      eq 0
      expect(smoke_detector.simpleonoff_state).to      eq 0
      expect(smoke_detector.powermeter_voltage).to     eq 237894
      expect(smoke_detector.powermeter_power).to       eq 0
      expect(smoke_detector.powermeter_energy).to      eq 244
      expect(smoke_detector.temperature_celsius).to    eq 200
      expect(smoke_detector.temperature_offset).to     eq -5
      expect(smoke_detector.group_members).to          be nil
    end
  end
end
