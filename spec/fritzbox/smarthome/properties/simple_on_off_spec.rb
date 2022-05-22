# frozen_string_literal: true

RSpec.describe Fritzbox::Smarthome::Properties::SimpleOnOff do
  subject(:instance) { generic_class.new }

  let(:generic_class) do
    Class.new {
      def ain
        @ain ||= ("A".."Z").to_a.shuffle.sample(6).join
      end
    }.include described_class
  end

  it "adds a `new_from_api` class method if it doesn't exist" do
    expect(generic_class).to respond_to(:new_from_api).with(1).argument
  end

  it "adds a `simpleonoff_state` accessor" do
    expect(instance).to respond_to(:simpleonoff_state).with(0).arguments
    expect(instance).to respond_to(:simpleonoff_state=).with(1).arguments
  end

  it "adds an `active?` predicate method" do
    expect(instance).to respond_to(:active?).with(0).arguments

    expect { instance.simpleonoff_state = "1" }
      .to change { instance.active? }
      .to true

    expect { instance.simpleonoff_state = :anything_else }
      .to change { instance.active? }
      .to false
  end

  describe "#toggle!" do
    let(:response) { double("HTTP Response") }

    before do
      allow(Fritzbox::Smarthome::Resource).to receive(:get).and_return(response)
    end

    context "when the receiver doesn't respond to `#ain`" do
      before do
        instance.singleton_class.undef_method :ain
      end

      it "raises an ArgumentError" do
        expect { instance.toggle! }
          .to raise_error(ArgumentError, /Attribute `ain` is missing on/)
      end
    end

    context "when the device is currently OFF" do
      subject(:toggle!) { instance_on.toggle! }

      let(:instance_off) { instance.tap { |o| o.simpleonoff_state = "0" } }

      context "when the GET request is successful" do
        before do
          allow(response).to receive(:ok?).and_return(true)
        end

        it "changes the active state" do
          retval = nil

          expect { retval = instance_off.toggle! }
            .to change { instance_off.active? }
            .from(false)
            .to(true)

          expect(Fritzbox::Smarthome::Resource).to have_received(:get)
            .with(command: 'setsimpleonoff', ain: String, onoff: 1)

          expect(retval).to be 1
        end
      end

      context "when the GET request is unsuccessful" do
        before do
          allow(response).to receive(:ok?).and_return(false)
        end

        it "leaves the active state untouched" do
          retval = nil

          expect { retval = instance_off.toggle! }
            .not_to change { instance_off.active? }

          expect(Fritzbox::Smarthome::Resource).to have_received(:get)
            .with(command: 'setsimpleonoff', ain: String, onoff: 1)

          expect(retval).to be false
        end
      end
    end

    context "when the device is currently ON" do
      subject(:toggle!) { instance_on.toggle! }

      let!(:instance_on) { instance.tap { |o| o.simpleonoff_state = "1" } }

      context "when the GET request is successful" do
        before do
          allow(response).to receive(:ok?).and_return(true)
        end

        it "changes the active state" do
          retval = nil

          expect { retval = toggle! }
            .to change { instance_on.active? }
            .from(true)
            .to(false)

          expect(Fritzbox::Smarthome::Resource).to have_received(:get)
            .with(command: 'setsimpleonoff', ain: String, onoff: 0)

          expect(retval).to be 0
        end
      end

      context "when the GET request is unsuccessful" do
        before do
          allow(response).to receive(:ok?).and_return(false)
        end

        it "leaves the active state untouched" do
          retval = nil

          expect { retval = toggle! }
            .not_to change { instance_on.active? }

          expect(Fritzbox::Smarthome::Resource).to have_received(:get)
            .with(command: 'setsimpleonoff', ain: String, onoff: 0)

          expect(retval).to be false
        end
      end
    end
  end
end
