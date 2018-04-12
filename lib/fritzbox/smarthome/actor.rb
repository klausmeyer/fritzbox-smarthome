module Fritzbox
  module Smarthome
    class Actor < Resource
      include ActiveModel::Model

      attr_accessor \
        :id,
        :type,
        :ain,
        :present,
        :name,
        :hkr_temp_is,
        :hkr_temp_set,
        :hkr_next_change_period,
        :hkr_next_change_temp,
        :group_members

      class << self
        def all(types: ['group', 'device'])
          response = get(command: 'getdevicelistinfos')
          xml = nori.parse(response.body)

          Array.wrap(types.map { |type| xml.dig('devicelist', type) }.flatten).map do |data|
            new_from_api(data)
          end
        end

        def only_heaters
          all.select { |record| record.hkr_temp_is.present? }
        end

        def new_from_api(data)
          new(
            id:                     data.dig('@id').to_s,
            type:                   data.dig('groupinfo').present? ? :group : :device,
            ain:                    data.dig('@identifier').to_s,
            present:                data.dig('present') == '1',
            name:                   data.dig('name').to_s,
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
