module Fritzbox
  module Smarthome
    class Switch < Actor
      include Properties::SimpleOnOff

      attribute :switch_state, :integer
      attribute :switch_mode, :string
      attribute :switch_lock, :integer
      attribute :switch_devicelock, :integer
      attribute :powermeter_voltage, :integer
      attribute :powermeter_power, :integer
      attribute :powermeter_energy, :integer
      attribute :temperature_celsius, :integer
      attribute :temperature_offset, :integer

      class << self
        def match?(data)
          data.key?('switch')
        end
      end

      def assign_from_api(data)
        super(data)

        assign_attributes(
          switch_state:        data.dig('switch', 'state'),
          switch_mode:         data.dig('switch', 'mode'),
          switch_lock:         data.dig('switch', 'lock'),
          switch_devicelock:   data.dig('switch', 'devicelock'),
          powermeter_voltage:  data.dig('powermeter', 'voltage'),
          powermeter_power:    data.dig('powermeter', 'power'),
          powermeter_energy:   data.dig('powermeter', 'energy'),
          temperature_celsius: data.dig('temperature', 'celsius'),
          temperature_offset:  data.dig('temperature', 'offset')
        )
      end
    end
  end
end
