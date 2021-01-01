require 'spec_helper'

RSpec.describe Fritzbox::Smarthome::Actor do
  before do
    stub_request(:get, 'https://fritz.box/login_sid.lua').
      to_return(body: '<SessionInfo><Challenge>1234567z</Challenge></SessionInfo>')

    stub_request(:get, 'https://fritz.box/login_sid.lua?response=1234567z-8d08321fe007cd28e2eae9f9051628db&username=smarthome').
      to_return(body: '<SessionInfo><SID>ff88e4d39354992f</SID></SessionInfo>')
  end

  describe '.all' do
    it 'returns a list of actors' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))

      actors = described_class.all
      expect(actors.size).to eq 2

      actor = actors.shift
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '18'
      expect(actor.ain).to                    eq '12345 678901'
      expect(actor.name).to                   eq 'Heizung Wohnzimmer'
      expect(actor.manufacturer).to           eq 'AVM'
      expect(actor.battery).to                eq 80
      expect(actor.batterylow).to             eq 0
      expect(actor.hkr_temp_is).to            eq 20.5
      expect(actor.hkr_temp_set).to           eq 16.0
      expect(actor.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(actor.hkr_next_change_temp).to   eq 23.0
      expect(actor.group_members).to          be nil

      actor = actors.shift
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '16'
      expect(actor.ain).to                    eq '12345 678902'
      expect(actor.name).to                   eq 'Heizung Küche'
      expect(actor.manufacturer).to           eq 'AVM'
      expect(actor.battery).to                eq 10
      expect(actor.batterylow).to             eq 1
      expect(actor.hkr_temp_is).to            eq 20.5
      expect(actor.hkr_temp_set).to           eq 16.0
      expect(actor.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(actor.hkr_next_change_temp).to   eq 23.0
      expect(actor.group_members).to          be nil
    end

    it 'returns a list of actors and group' do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getactorandgrouplistinfos.xml', __FILE__)))

      actors = described_class.all
      expect(actors.size).to eq 3

      actor = actors.shift
      expect(actor.type).to                   eq :group
      expect(actor.id).to                     eq '900'
      expect(actor.ain).to                    eq '65:0A:0C-900'
      expect(actor.name).to                   eq 'Heizungen'
      expect(actor.hkr_temp_is).to            eq 21.0
      expect(actor.hkr_temp_set).to           eq 16.0
      expect(actor.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(actor.hkr_next_change_temp).to   eq 23.0
      expect(actor.group_members).to          eq ['18', '16']

      actor = actors.shift
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '18'
      expect(actor.ain).to                    eq '12345 678901'
      expect(actor.name).to                   eq 'Heizung Wohnzimmer'
      expect(actor.manufacturer).to           eq 'AVM'
      expect(actor.battery).to                eq 80
      expect(actor.batterylow).to             eq 0
      expect(actor.hkr_temp_is).to            eq 20.5
      expect(actor.hkr_temp_set).to           eq 16.0
      expect(actor.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(actor.hkr_next_change_temp).to   eq 23.0
      expect(actor.group_members).to          be nil

      actor = actors.shift
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '16'
      expect(actor.ain).to                    eq '12345 678902'
      expect(actor.name).to                   eq 'Heizung Küche'
      expect(actor.manufacturer).to           eq 'AVM'
      expect(actor.battery).to                eq 80
      expect(actor.batterylow).to             eq 0
      expect(actor.hkr_temp_is).to            eq 20.5
      expect(actor.hkr_temp_set).to           eq 16.0
      expect(actor.hkr_next_change_period).to eq Time.new(2018, 4, 10, 6, 0, 0, '+02:00')
      expect(actor.hkr_next_change_temp).to   eq 23.0
      expect(actor.group_members).to          be nil
    end
  end

  describe '#update_hkr_temp_set' do
    before do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?ain=12345%20678902&param=40&sid=ff88e4d39354992f&switchcmd=sethkrtsoll').
        to_return(body: "40\n")
    end

    it 'sends the update command and returns true' do
      actor = described_class.new(ain: '12345 678902')
      expect(actor.update_hkr_temp_set(BigDecimal('20.0'))).to be true
    end
  end
end
