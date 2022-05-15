# frozen_string_literal: true

RSpec.describe Fritzbox::Smarthome::NullLogger do

  shared_examples_for 'a Ruby `Logger`-compatible interface' do |meth|
    describe "##{meth}" do
      it "will not output anything" do
        expect { described_class.new.public_send(meth) }
          .to_not output.to_stdout
        expect { described_class.new.public_send(meth) }
          .to_not output.to_stderr
      end
    end
  end

  it_behaves_like 'a Ruby `Logger`-compatible interface', :info
  it_behaves_like 'a Ruby `Logger`-compatible interface', :warn
  it_behaves_like 'a Ruby `Logger`-compatible interface', :error
  it_behaves_like 'a Ruby `Logger`-compatible interface', :fatal
  it_behaves_like 'a Ruby `Logger`-compatible interface', :debug
end
