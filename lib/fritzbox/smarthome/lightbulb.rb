module Fritzbox
  module Smarthome
    class Lightbulb < Actor
      include Properties::SimpleOnOff

      class << self
        def match?(data)
          data.fetch('@productname', '') =~ /FRITZ!DECT 5\d{2}/i
        end
      end
    end
  end
end
