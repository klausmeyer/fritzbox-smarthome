module Fritzbox
  module Smarthome
    class NullLogger < Logger
      def initialize(*_args)
        super(File::NULL)
      end
    end
  end
end
