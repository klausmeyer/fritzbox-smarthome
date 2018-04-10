require 'active_model'
require 'active_support/all'
require 'httparty'
require 'nori'

require 'fritzbox/smarthome/version'
require "fritzbox/smarthome/resource"
require 'fritzbox/smarthome/actor'

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
      defaults.logger     = nil
    end

    class << self
      def configure(&block)
        block.yield(@config)
      end

      attr_reader :config
    end
  end
end
