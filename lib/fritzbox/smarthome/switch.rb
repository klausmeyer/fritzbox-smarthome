module Fritzbox
  module Smarthome
    class Switch < Device

      attr_accessor \
        :switch_state,
        :switch_mode,
        :switch_lock,
        :switch_devicelock,
        :simpleonoff_state,
        :powermeter_voltage,
        :powermeter_power,
        :powermeter_energy,
        :temperature_celsius,
        :temperature_offset

      class << self
        def new_from_api(data)
          return if data.dig('switch', 'state') == nil
          new(
            id:                     data.dig('@id').to_s,
            type:                   data.dig('groupinfo').present? ? :group : :device,
            ain:                    data.dig('@identifier').to_s,
            present:                data.dig('present') == '1',
            name:                   data.dig('name').to_s,
            manufacturer:           data.dig('manufacturer').to_s,
            switch_state:           data.dig('switch', 'state').to_i,
            switch_mode:            data.dig('switch', 'mode').to_s,
            switch_lock:            data.dig('switch', 'lock').to_i,
            switch_devicelock:      data.dig('switch', 'devicelock').to_i,
            simpleonoff_state:      data.dig('simpleonoff', 'state').to_i,
            powermeter_voltage:     data.dig('powermeter', 'voltage').to_i,
            powermeter_power:       data.dig('powermeter', 'power').to_i,
            powermeter_energy:      data.dig('powermeter', 'energy').to_i,
            temperature_celsius:    data.dig('temperature', 'celsius').to_i,
            temperature_offset:     data.dig('temperature', 'offset').to_i,
            group_members:          data.dig('groupinfo', 'members').to_s.split(',').presence
          )
        end
      end
    end
  end
end
