require 'spec_helper'

RSpec.describe Fritzbox::Smarthome::Heater do
  before do
    stub_request(:get, 'https://fritz.box/login_sid.lua').
      to_return(body: '<SessionInfo><Challenge>1234567z</Challenge></SessionInfo>')

    stub_request(:get, 'https://fritz.box/login_sid.lua?response=1234567z-8d08321fe007cd28e2eae9f9051628db&username=smarthome').
      to_return(body: '<SessionInfo><SID>ff88e4d39354992f</SID></SessionInfo>')
  end

  describe '.all' do
    it 'returns a list of heaters' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))

      heaters = described_class.all
      expect(heaters.size).to eq 2

      heater = heaters.shift
      expect(heater.attributes).to include(
        'type'                   => :device,
        'id'                     => '18',
        'ain'                    => '12345 678901',
        'name'                   => 'Heizung Wohnzimmer',
        'manufacturer'           => 'AVM',
        'battery'                => 80,
        'batterylow'             => 0,
        'hkr_temp_is'            => 20.5,
        'hkr_temp_set'           => 16.0,
        'hkr_next_change_period' => Time.new(2018, 4, 10, 6, 0, 0, '+02:00'),
        'hkr_next_change_temp'   => 23.0,
        'group_members'          => nil,
      )

      heater = heaters.shift
      expect(heater.attributes).to include(
        'type'                   => :device,
        'id'                     => '16',
        'ain'                    => '12345 678902',
        'name'                   => 'Heizung Küche',
        'manufacturer'           => 'AVM',
        'battery'                => 10,
        'batterylow'             => 1,
        'hkr_temp_is'            => 20.5,
        'hkr_temp_set'           => 16.0,
        'hkr_next_change_period' => Time.new(2018, 4, 10, 6, 0, 0, '+02:00'),
        'hkr_next_change_temp'   => 23.0,
        'group_members'          => nil,
      )
    end

    it 'returns a list of heaters and group' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getheaterandgrouplistinfos.xml', __FILE__)))

      heaters = described_class.all
      expect(heaters.size).to eq 3

      heater = heaters.shift
      expect(heater.attributes).to include(
        'type'                   => :group,
        'id'                     => '900',
        'ain'                    => '65:0A:0C-900',
        'name'                   => 'Heizungen',
        'hkr_temp_is'            => 21.0,
        'hkr_temp_set'           => 16.0,
        'hkr_next_change_period' => Time.new(2018, 4, 10, 6, 0, 0, '+02:00'),
        'hkr_next_change_temp'   => 23.0,
        'group_members'          => ['18', '16'],
      )

      heater = heaters.shift
      expect(heater.attributes).to include(
        'type'                   => :device,
        'id'                     => '18',
        'ain'                    => '12345 678901',
        'name'                   => 'Heizung Wohnzimmer',
        'manufacturer'           => 'AVM',
        'battery'                => 80,
        'batterylow'             => 0,
        'hkr_temp_is'            => 20.5,
        'hkr_temp_set'           => 16.0,
        'hkr_next_change_period' => Time.new(2018, 4, 10, 6, 0, 0, '+02:00'),
        'hkr_next_change_temp'   => 23.0,
        'group_members'          => nil,
      )

      heater = heaters.shift
      expect(heater.attributes).to include(
        'type'                   => :device,
        'id'                     => '16',
        'ain'                    => '12345 678902',
        'name'                   => 'Heizung Küche',
        'manufacturer'           => 'AVM',
        'battery'                => 80,
        'batterylow'             => 0,
        'hkr_temp_is'            => 20.5,
        'hkr_temp_set'           => 16.0,
        'hkr_next_change_period' => Time.new(2018, 4, 10, 6, 0, 0, '+02:00'),
        'hkr_next_change_temp'   => 23.0,
        'group_members'          => nil,
      )
    end
  end

  describe '#update_hkr_temp_set' do
    before do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?ain=12345%20678902&param=40&sid=ff88e4d39354992f&switchcmd=sethkrtsoll').
        to_return(body: "40\n")
    end

    it 'sends the update command and returns true' do
      heater = described_class.new(ain: '12345 678902')
      expect(heater.update_hkr_temp_set(BigDecimal('20.0'))).to be true
    end
  end
end
