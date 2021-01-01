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
        :manufacturer,
        :group_members,
        :device_type

      class << self
        def all(types: ['group', 'device'])
          response = get(command: 'getdevicelistinfos')
          xml = nori.parse(response.body)
          
          Array.wrap(types.map { |type| xml.dig('devicelist', type) }.flatten).compact.map do |data|
            new_from_api(data)
          end.compact
        end

        def new_from_api(data)
          @default_values = {
            id:                     data.dig('@id').to_s,
            type:                   data.dig('groupinfo').present? ? :group : :device,
            ain:                    data.dig('@identifier').to_s,
            present:                data.dig('present') == '1',
            name:                   data.dig('name').to_s,
            manufacturer:           data.dig('manufacturer').to_s,
            group_members:          data.dig('groupinfo', 'members').to_s.split(',').presence
            # TODO: implement device type
          }
          new(**@default_values.merge(@values || {}))
        end
      end
    end
  end
end
