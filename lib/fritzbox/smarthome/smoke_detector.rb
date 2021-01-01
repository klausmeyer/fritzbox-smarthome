module Fritzbox
  module Smarthome
    class SmokeDetector < Actor

      attr_accessor \
        :alert_state,
        :last_alert

      class << self
        def new_from_api(data)
          return if data.dig('alert', 'state') == nil
          @values = {
            alert_state:            data.dig('alert', 'state').to_i,
            last_alert:             Time.at(data.dig('alert', 'lastalertchgtimestamp').to_i)
          }
          super
        end
      end
    end
  end
end
