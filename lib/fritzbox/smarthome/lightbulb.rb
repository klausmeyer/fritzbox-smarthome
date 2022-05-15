# frozen_string_literal: true

module Fritzbox
  module Smarthome
    class Lightbulb < Actor

      attr_accessor \
        :simpleonoff_state

      class << self
        def match?(data)
          data.fetch('@productname', '') =~ /FRITZ!DECT 5\d{2}/i
        end

        def new_from_api(data)
          instance = super
          instance.assign_attributes(
            simpleonoff_state:   data.dig('simpleonoff', 'state').to_i,
          )
          instance
        end
      end

      def active?
        simpleonoff_state == 1
      end

      def toggle!
        value = active? ? 0 : 1
        response = self.class.get(command: 'setsimpleonoff', ain: ain, onoff: value)

        response.ok? && @simpleonoff_state = value
      end
    end
  end
end
