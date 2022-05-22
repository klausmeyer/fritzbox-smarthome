require 'active_model'
require 'active_support/all'
require 'httparty'
require 'nori'

require 'fritzbox/smarthome/version'
require 'fritzbox/smarthome/null_logger'
require 'fritzbox/smarthome/properties'
require 'fritzbox/smarthome/resource'
require 'fritzbox/smarthome/actor'
require 'fritzbox/smarthome/heater'
require 'fritzbox/smarthome/switch'
require 'fritzbox/smarthome/smoke_detector'
require 'fritzbox/smarthome/lightbulb'

module Fritzbox
  module Smarthome
    class Configuration
      include ActiveModel::Model

      attr_accessor \
        :endpoint, \
        :username, \
        :password,
        :verify_ssl,
        :logger
    end

    @config = Configuration.new.tap do |defaults|
      defaults.endpoint   = 'https://fritz.box'
      defaults.username   = 'smarthome'
      defaults.password   = 'verysmart'
      defaults.verify_ssl = true
      defaults.logger     = NullLogger.new
    end

    class << self
      def configure(&block)
        block.yield(@config)
      end

      attr_reader :config
    end
  end
end
