require 'spec_helper'

RSpec.describe Fritzbox::Smarthome::Actor do
  let!(:login_challenge_request) do
    stub_request(:get, 'https://fritz.box/login_sid.lua').
      to_return(body: '<SessionInfo><Challenge>1234567z</Challenge></SessionInfo>')
  end

  let!(:login_response_request) do
    stub_request(:get, 'https://fritz.box/login_sid.lua?response=1234567z-8d08321fe007cd28e2eae9f9051628db&username=smarthome').
      to_return(body: '<SessionInfo><SID>ff88e4d39354992f</SID></SessionInfo>')
  end

  describe 'caching of authentication' do
    before do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))

      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?ain=12345%20678901&sid=ff88e4d39354992f&switchcmd=getdeviceinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdeviceinfos.xml', __FILE__)))
    end

    it 'caches the authorization between requests' do
      list  = described_class.all
      actor = described_class.find_by!(ain: list.first.ain)

      expect(login_challenge_request).to have_been_made.once
      expect(login_response_request).to have_been_made.once
    end
  end

  describe '.all' do
    before do
      stub_request(:get, 'https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=getdevicelistinfos').
        to_return(body: File.read(File.expand_path('../../../support/fixtures/getdevicelistinfos.xml', __FILE__)))
    end

    it 'returns a list of all actors' do
      actors = described_class.all
      expect(actors.size).to eq 7

      actor = actors.shift
      expect(actor.class).to eq Fritzbox::Smarthome::Heater
      expect(actor.attributes).to include(
        'type'          => :device,
        'id'            => '18',
        'ain'           => '12345 678901',
        'name'          => 'Heizung Wohnzimmer',
        'manufacturer'  => 'AVM',
        'group_members' => nil,
      )

      actor = actors.shift
      expect(actor.class).to eq Fritzbox::Smarthome::Heater
      expect(actor.attributes).to include(
        'type'          => :device,
        'id'            => '16',
        'ain'           => '12345 678902',
        'name'          => 'Heizung Küche',
        'manufacturer'  => 'AVM',
        'group_members' => nil,
      )

      actor = actors.shift
      expect(actor.class).to eq Fritzbox::Smarthome::SmokeDetector
      expect(actor.attributes).to include(
        'type'          => :device,
        'id'            => '15',
        'ain'           => '12345 678903',
        'name'          => 'Rauchmelder Wohnzimmer',
        'manufacturer'  => '0x2c3c',
        'group_members' => nil,
      )

      actor = actors.shift
      expect(actor.class).to eq Fritzbox::Smarthome::SmokeDetector
      expect(actor.attributes).to include(
        'type'          => :device,
        'id'            => '14',
        'ain'           => '12345 678904',
        'name'          => 'Rauchmelder Küche',
        'manufacturer'  => '0x2c3c',
        'group_members' => nil,
      )

      actor = actors.shift
      expect(actor.class).to eq Fritzbox::Smarthome::Switch
      expect(actor.attributes).to include(
        'type'          => :device,
        'id'            => '13',
        'ain'           => '12345 678905',
        'name'          => 'FRITZ!DECT 200 Steckdose',
        'manufacturer'  => 'AVM',
        'group_members' => nil,
      )

      # An unrecognised device that couldn't be linked to a specific Actor subclass:
      actor = actors.shift
      expect(actor.class).to eq Fritzbox::Smarthome::Actor
      expect(actor.attributes).to include(
        'type'          => :device,
        'id'            => '4711',
        'ain'           => '12345 54321',
        'name'          => 'Sub-Etha Radio Transmitter',
        'manufacturer'  => '',
        'group_members' => nil,
      )

      actor = actors.shift
      expect(actor.class).to eq Fritzbox::Smarthome::Lightbulb
      expect(actor.attributes).to include(
        'type'          => :device,
        'id'            => '406',
        'ain'           => '11111 2233445',
        'name'          => 'Flurlampe',
        'manufacturer'  => 'AVM',
        'group_members' => nil,
      )
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
