module Fritzbox
  module Smarthome
    class SmokeDetector < Actor
      attribute :alert_state, :integer
      attribute :last_alert, :time

      class << self
        def match?(data)
          data.key?('alert')
        end
      end

      def assign_from_api(data)
        super(data)

        assign_attributes(
          alert_state: data.dig('alert', 'state').to_i,
          last_alert:  Time.at(data.dig('alert', 'lastalertchgtimestamp').to_i)
        )
      end
    end
  end
end
