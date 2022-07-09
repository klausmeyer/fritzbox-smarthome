# frozen_string_literal: true

RSpec.shared_examples_for "a device with a simple on/off interface" do
  subject(:device) do described_class.new
    described_class.new_from_api({ 'simpleonoff' => { 'state' => state } })
  end



  describe '#active?' do
    subject { device.active? }

    context 'when simpleonoff_state is "0"' do
      let(:state) { '0' }
      it { is_expected.to be false }
    end

    context 'when simpleonoff_state is "1"' do
      let(:state) { '1' }
      it { is_expected.to be true }
    end
  end

  describe '#toggle!' do
    before { stub_request(:get, api_cmd_url).to_return(status: 200) }

    let(:api_cmd_url) do
      "https://fritz.box/webservices/homeautoswitch.lua?sid=ff88e4d39354992f&switchcmd=setsimpleonoff&#{device.ain}&onoff=#{onoff}"
    end

    context 'when the device is off' do
      let(:state) { "0" }
      let(:onoff) { "1" }

      it "switches the device on" do
        expect { device.toggle! }
          .to change { device.active? }
          .from(false).to(true)

        expect(a_request(:get, api_cmd_url)).to have_been_made.once
      end
    end

    context 'when the device is on' do
      let(:state) { "1" }
      let(:onoff) { "0" }

      it "switches the device off" do
        expect { device.toggle! }
          .to change { device.active? }
          .from(true).to(false)

        expect(a_request(:get, api_cmd_url)).to have_been_made.once
      end
    end
  end
end
