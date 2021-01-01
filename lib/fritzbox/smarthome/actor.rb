module Fritzbox
  module Smarthome
    class Actor < Device

      attr_accessor \
        :battery,
        :batterylow,
        :hkr_temp_is,
        :hkr_temp_set,
        :hkr_next_change_period,
        :hkr_next_change_temp

      class << self
        def new_from_api(data)
          return nil if data.dig('hkr') == nil
          new(
            id:                     data.dig('@id').to_s,
            type:                   data.dig('groupinfo').present? ? :group : :device,
            ain:                    data.dig('@identifier').to_s,
            present:                data.dig('present') == '1',
            name:                   data.dig('name').to_s,
            manufacturer:           data.dig('manufacturer').to_s,
            battery:                data.dig('battery').to_i,
            batterylow:             data.dig('batterylow').to_i,
            hkr_temp_is:            data.dig('hkr', 'tist').to_i * 0.5,
            hkr_temp_set:           data.dig('hkr', 'tsoll').to_i * 0.5,
            hkr_next_change_period: Time.at(data.dig('hkr', 'nextchange', 'endperiod').to_i),
            hkr_next_change_temp:   data.dig('hkr', 'nextchange', 'tchange').to_i * 0.5,
            group_members:          data.dig('groupinfo', 'members').to_s.split(',').presence
          )
        end
      end

      def update_hkr_temp_set(value)
        raise ArgumentError unless value.is_a? BigDecimal
        value = (value / 0.5).to_i
        response = self.class.get(command: 'sethkrtsoll', ain: ain, param: value)
        raise 'Could not set temperature' unless response.body == "#{value}\n"
        true
      end
    end
  end
end
