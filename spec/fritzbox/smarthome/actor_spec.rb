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
      expect(actors.size).to eq 7

      actor = actors.shift
      expect(actor.class).to                  eq Fritzbox::Smarthome::Heater
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '18'
      expect(actor.ain).to                    eq '12345 678901'
      expect(actor.name).to                   eq 'Heizung Wohnzimmer'
      expect(actor.manufacturer).to           eq 'AVM'
      expect(actor.group_members).to          be nil

      actor = actors.shift
      expect(actor.class).to                  eq Fritzbox::Smarthome::Heater
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '16'
      expect(actor.ain).to                    eq '12345 678902'
      expect(actor.name).to                   eq 'Heizung Küche'
      expect(actor.manufacturer).to           eq 'AVM'
      expect(actor.group_members).to          be nil

      actor = actors.shift
      expect(actor.class).to                  eq Fritzbox::Smarthome::SmokeDetector
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '15'
      expect(actor.ain).to                    eq '12345 678903'
      expect(actor.name).to                   eq 'Rauchmelder Wohnzimmer'
      expect(actor.manufacturer).to           eq '0x2c3c'
      expect(actor.group_members).to          be nil

      actor = actors.shift
      expect(actor.class).to                  eq Fritzbox::Smarthome::SmokeDetector
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '14'
      expect(actor.ain).to                    eq '12345 678904'
      expect(actor.name).to                   eq 'Rauchmelder Küche'
      expect(actor.manufacturer).to           eq '0x2c3c'
      expect(actor.group_members).to          be nil

      actor = actors.shift
      expect(actor.class).to                  eq Fritzbox::Smarthome::Switch
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq '13'
      expect(actor.ain).to                    eq '12345 678905'
      expect(actor.name).to                   eq 'FRITZ!DECT 200 Steckdose'
      expect(actor.manufacturer).to           eq 'AVM'
      expect(actor.group_members).to          be nil

      # An unrecognised device that couldn't be linked to a specific Actor subclass:
      actor = actors.shift
      expect(actor.class).to                  eq Fritzbox::Smarthome::Actor
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq "4711"
      expect(actor.ain).to                    eq "12345 54321"
      expect(actor.name).to                   eq "Sub-Etha Radio Transmitter"
      expect(actor.manufacturer).to           eq ""
      expect(actor.group_members).to          be nil

      actor = actors.shift
      expect(actor.class).to                  eq Fritzbox::Smarthome::Lightbulb
      expect(actor.type).to                   eq :device
      expect(actor.id).to                     eq "406"
      expect(actor.ain).to                    eq "11111 2233445"
      expect(actor.name).to                   eq "Flurlampe"
      expect(actor.manufacturer).to           eq "AVM"
      expect(actor.group_members).to          be nil
    end
  end

  describe '.new_from_api' do
    subject(:actor) { described_class.new_from_api(data) }

    let(:data) { Hash.new }

    context 'when setting the manufacturer' do
      let!(:data) { { '@manufacturer' => 'Orang-Utan Klaus' } }

      it 'sets #manufacturer based on an XML attribute' do
        expect(actor.manufacturer).to eql 'Orang-Utan Klaus'
      end

      context "when an XML node is present" do
        let!(:data) { { '@manufacturer' => 'Orang-Utan Klaus', 'manufacturer' => 'Telefonmann' } }

        it "takes precedence over a @manufacturer XML attribute" do
          expect(actor.manufacturer).to eql 'Telefonmann'
        end
      end
    end
  end

  describe '.find_by!(ain:)' do
    let(:ain) { '0815 4711' }

    before do
      stub_request(:get, "https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdeviceinfos&ain=#{ain}").
        to_return(body: response_body)
    end

    context 'with an ain known by the api' do
      let(:response_body) do
        File.read(File.expand_path('../../../support/fixtures/getdeviceinfos.xml', __FILE__))
      end

      it 'returns an instance filled with data' do
        actor = described_class.find_by!(ain: ain)

        expect(actor.ain).to eq ain
        expect(actor.manufacturer).to eq 'ACME'
      end
    end

    context 'with an unknown ain' do
      let(:response_body) do
        '{}'
      end

      it 'raises a ResourceNotFound error' do
        expect { described_class.find_by!(ain: ain) }.to raise_error Fritzbox::Smarthome::Actor::ResourceNotFound, "Unable to find actor with ain='#{ain}'"
      end
    end
  end

  describe '#reload' do
    let(:ain) { '0815 4711' }

    before do
      stub_request(:get, "https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdeviceinfos&ain=#{ain}").
        to_return(body: response_body)
    end

    context 'with an ain known by the api' do
      let(:response_body) do
        File.read(File.expand_path('../../../support/fixtures/getdeviceinfos.xml', __FILE__))
      end

      it 'returns an instance filled with data' do
        actor = described_class.new(ain: ain)
        actor.manufacturer = 'DUMMY'

        actor.reload

        expect(actor.manufacturer).to eq 'ACME'
      end
    end

    context 'with an unknown ain' do
      let(:response_body) do
        '{}'
      end

      it 'raises a ResourceNotFound error' do
        actor = described_class.new(ain: ain)

        expect { actor.reload }.to raise_error Fritzbox::Smarthome::Actor::ResourceNotFound, "Unable to reload actor with ain='#{ain}'"
      end
    end
  end
end
