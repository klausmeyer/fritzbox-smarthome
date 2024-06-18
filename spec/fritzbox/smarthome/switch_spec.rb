require 'spec_helper'

RSpec.describe Fritzbox::Smarthome::Switch do
  before do
    stub_request(:get, 'https://fritz.box/login_sid.lua').
      to_return(body: '<SessionInfo><Challenge>1234567z</Challenge></SessionInfo>')

    stub_request(:get, 'https://fritz.box/login_sid.lua?response=1234567z-8d08321fe007cd28e2eae9f9051628db&username=smarthome').
      to_return(body: '<SessionInfo><SID>ff88e4d39354992f</SID></SessionInfo>')
  end

  it_behaves_like "a device with a simple on/off interface"

  describe '.all' do
    it 'returns a list of switches' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))

      smoke_detectors = described_class.all
      expect(smoke_detectors.size).to eq 1

      smoke_detector = smoke_detectors.shift
      expect(smoke_detector.attributes).to include(
        'type'                => :device,
        'id'                  => '13',
        'ain'                 => '12345 678905',
        'name'                => 'FRITZ!DECT 200 Steckdose',
        'manufacturer'        => 'AVM',
        'switch_state'        => 0,
        'switch_mode'         => 'manuell',
        'switch_lock'         => 0,
        'switch_devicelock'   => 0,
        'simpleonoff_state'   => 0,
        'powermeter_voltage'  => 237894,
        'powermeter_power'    => 0,
        'powermeter_energy'   => 244,
        'temperature_celsius' => 200,
        'temperature_offset'  => -5,
        'group_members'       => nil,
      )
    end
  end
end
