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
      expect(heater.type).to                   eq :device
      expect(heater.id).to                     eq '18'
      expect(heater.ain).to                    eq '12345 678901'
      expect(heater.name).to                   eq 'Heizung Wohnzimmer'
      expect(heater.manufacturer).to           eq 'AVM'
      expect(heater.battery).to                eq 80
      expect(heater.batterylow).to             eq 0
      expect(heater.hkr_temp_is).to            eq 20.5
      expect(heater.hkr_temp_set).to           eq 16.0
      expect(heater.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(heater.hkr_next_change_temp).to   eq 23.0
      expect(heater.group_members).to          be nil

      heater = heaters.shift
      expect(heater.type).to                   eq :device
      expect(heater.id).to                     eq '16'
      expect(heater.ain).to                    eq '12345 678902'
      expect(heater.name).to                   eq 'Heizung Küche'
      expect(heater.manufacturer).to           eq 'AVM'
      expect(heater.battery).to                eq 10
      expect(heater.batterylow).to             eq 1
      expect(heater.hkr_temp_is).to            eq 20.5
      expect(heater.hkr_temp_set).to           eq 16.0
      expect(heater.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(heater.hkr_next_change_temp).to   eq 23.0
      expect(heater.group_members).to          be nil
    end

    it 'returns a list of heaters and group' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getheaterandgrouplistinfos.xml', __FILE__)))

      heaters = described_class.all
      expect(heaters.size).to eq 3

      heater = heaters.shift
      expect(heater.type).to                   eq :group
      expect(heater.id).to                     eq '900'
      expect(heater.ain).to                    eq '65:0A:0C-900'
      expect(heater.name).to                   eq 'Heizungen'
      expect(heater.hkr_temp_is).to            eq 21.0
      expect(heater.hkr_temp_set).to           eq 16.0
      expect(heater.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(heater.hkr_next_change_temp).to   eq 23.0
      expect(heater.group_members).to          eq ['18', '16']

      heater = heaters.shift
      expect(heater.type).to                   eq :device
      expect(heater.id).to                     eq '18'
      expect(heater.ain).to                    eq '12345 678901'
      expect(heater.name).to                   eq 'Heizung Wohnzimmer'
      expect(heater.manufacturer).to           eq 'AVM'
      expect(heater.battery).to                eq 80
      expect(heater.batterylow).to             eq 0
      expect(heater.hkr_temp_is).to            eq 20.5
      expect(heater.hkr_temp_set).to           eq 16.0
      expect(heater.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(heater.hkr_next_change_temp).to   eq 23.0
      expect(heater.group_members).to          be nil

      heater = heaters.shift
      expect(heater.type).to                   eq :device
      expect(heater.id).to                     eq '16'
      expect(heater.ain).to                    eq '12345 678902'
      expect(heater.name).to                   eq 'Heizung Küche'
      expect(heater.manufacturer).to           eq 'AVM'
      expect(heater.battery).to                eq 80
      expect(heater.batterylow).to             eq 0
      expect(heater.hkr_temp_is).to            eq 20.5
      expect(heater.hkr_temp_set).to           eq 16.0
      expect(heater.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(heater.hkr_next_change_temp).to   eq 23.0
      expect(heater.group_members).to          be nil
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
