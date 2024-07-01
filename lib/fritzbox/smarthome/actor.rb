module Fritzbox
  module Smarthome
    class Actor < Resource
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :id, :string
      attribute :type #, :symbol
      attribute :ain, :string
      attribute :present, :string
      attribute :name, :string
      attribute :manufacturer, :string
      attribute :group_members #, :string, array: true

      ResourceNotFound = Class.new(RuntimeError)

      class << self
        def all(types: ['group', 'device'])
          xml = parse(get(command: 'getdevicelistinfos'))

          Array.wrap(types.map { |type| xml.dig('devicelist', type) }.flatten).compact.map do |data|
            klass = Actor.descendants.find { |k| k.match?(data) } || Actor
            self.in?([klass, Actor]) ? klass.new_from_api(data) : nil
          end.compact
        end

        def find_by!(ain: nil)
          data = parse(get(command: 'getdeviceinfos', ain: ain)).fetch('device')
          klass = Actor.descendants.find { |k| k.match?(data) } || Actor

          instance = klass.new(ain: ain)
          instance.assign_from_api(data)
          instance
        rescue KeyError
          raise ResourceNotFound, "Unable to find actor with ain='#{ain}'"
        end

        def new_from_api(data)
          instance = new
          instance.assign_from_api(data)
          instance
        end
      end

      def assign_from_api(data)
        assign_attributes(
          id:            data.dig('@id').to_s,
          type:          data.dig('groupinfo').present? ? :group : :device,
          ain:           data.dig('@identifier').to_s,
          present:       data.dig('present') == '1',
          name:          (data.dig('name') || data.dig('@productname')).to_s,
          manufacturer:  (data.dig('manufacturer') || data.dig('@manufacturer')).to_s,
          group_members: data.dig('groupinfo', 'members').to_s.split(',').presence
        )
      end

      def reload
        xml = parse(get(command: 'getdeviceinfos', ain: ain))
        assign_from_api(xml.fetch('device'))
        self
      rescue KeyError
        raise ResourceNotFound, "Unable to reload actor with ain='#{ain}'"
      end
    end
  end
end
