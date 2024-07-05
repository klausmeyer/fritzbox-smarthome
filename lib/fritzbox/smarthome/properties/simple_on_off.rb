# frozen_string_literal: true

module Fritzbox
  module Smarthome
    module Properties
      # Defines a common interface/behaviour for actors with the "simpleonoff" state.
      # The including class is expected to have an `ain` attribute defined.
      module SimpleOnOff
        extend ActiveSupport::Concern

        included do
          attribute :simpleonoff_state, :integer
        end

        module ClassMethods
          def new_from_api(data)
            instance = defined?(super) ? super : new
            instance.simpleonoff_state = data.dig('simpleonoff', 'state')
            instance
          end
        end

        # @return [Boolean]
        def active?
          simpleonoff_state == 1
        end

        # Makes a request to the Fritzbox and set the current instance's active state.
        #
        # The instance state is kept in memory and not checked with the Fritzbox state. It is
        # possible that the device is switched on/off through other means.
        #
        # @example
        #     lightbulb.active?
        #     # => true
        #     lightbulb.toggle!
        #     # => 0
        #     lightbulb.active?
        #     # => false
        # @return [false, Integer] Returns the new on/off state or false when the request
        #     was unsuccessful
        # @raise [ArgumentError] if the including class does not respond to `#ain`
        def toggle!
          raise ArgumentError, "Attribute `ain` is missing on #{inspect}" unless respond_to?(:ain)
          value = active? ? 0 : 1
          response = Fritzbox::Smarthome::Resource.get(command: 'setsimpleonoff', ain: ain, onoff: value)

          response.ok? && self.simpleonoff_state = value
        end
      end
    end
  end
end
