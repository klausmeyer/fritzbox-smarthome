module Fritzbox
  module Smarthome
    class Session
      TIMEOUT_MINUTES = 60

      def initialize(id)
        self.id = id
        self.valid_until = Time.now + TIMEOUT_MINUTES.minutes
      end

      def valid?
        self.valid_until > Time.now
      end

      attr_reader :id, :valid_until

      private

      attr_writer :id, :valid_until
    end
  end
end
