module Fritzbox
  module Smarthome
    class Heater < Actor

      attr_accessor \
        :battery,
        :batterylow,
        :hkr_temp_is,
        :hkr_temp_set,
        :hkr_next_change_period,
        :hkr_next_change_temp,
        :default_values

      class << self
        def new_from_api(data)
          return nil if data.dig('hkr') == nil
          @values = {
            battery:                data.dig('battery').to_i,
            batterylow:             data.dig('batterylow').to_i,
            hkr_temp_is:            data.dig('hkr', 'tist').to_i * 0.5,
            hkr_temp_set:           data.dig('hkr', 'tsoll').to_i * 0.5,
            hkr_next_change_period: Time.at(data.dig('hkr', 'nextchange', 'endperiod').to_i),
            hkr_next_change_temp:   data.dig('hkr', 'nextchange', 'tchange').to_i * 0.5
          }
          super
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
