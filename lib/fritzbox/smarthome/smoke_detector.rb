module Fritzbox
  module Smarthome
    class SmokeDetector < Actor

      attr_accessor \
        :alert_state,
        :last_alert

      class << self
        def match?(data)
          data.key?('alert')
        end

        def new_from_api(data)
          instance = super
          instance.assign_attributes(
             alert_state: data.dig('alert', 'state').to_i,
             last_alert:  Time.at(data.dig('alert', 'lastalertchgtimestamp').to_i)
          )
          instance
        end
      end
    end
  end
end
