module Fritzbox
  module Smarthome
    class SmokeDetector < Device

      attr_accessor \
        :alert_state,
        :last_alert

      class << self
        def new_from_api(data)
          new(
            id:                     data.dig('@id').to_s,
            type:                   data.dig('groupinfo').present? ? :group : :device,
            ain:                    data.dig('@identifier').to_s,
            present:                data.dig('present') == '1',
            name:                   data.dig('name').to_s,
            manufacturer:           data.dig('manufacturer').to_s,
            alert_state:            data.dig('alert', 'state').to_i,
            last_alert:             Time.at(data.dig('alert', 'lastalertchgtimestamp').to_i),
            group_members:          data.dig('groupinfo', 'members').to_s.split(',').presence
          )
        end
      end
    end
  end
end
