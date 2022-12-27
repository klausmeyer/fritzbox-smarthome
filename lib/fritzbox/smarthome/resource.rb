module Fritzbox
  module Smarthome
    class Resource
      cattr_accessor :session

      AuthenticationError = Class.new(RuntimeError)

      class << self
        # @param params [Hash] key/value pairs that will be appended to the switchcmd query string
        def get(command:, ain: nil, param: nil, **params)
          url = "#{config.endpoint}/webservices/homeautoswitch.lua?switchcmd=#{command}&sid=#{authenticate}"
          url = "#{url}&ain=#{ain}"     if ain.present?
          url = "#{url}&param=#{param}" if param.present?

          params.each_with_object(url) do |(key, value)|
            url = "#{url}&#{key}=#{value}"
          end

          response = measure(url) { HTTParty.get(url, **httparty_options) }

          raise AuthenticationError if response.code == 403

          response
        rescue AuthenticationError
          raise if session.nil?

          self.session = nil
          retry
        end

        def parse(response)
          nori.parse(response.body)
        end

        private

        delegate :config, to: Smarthome

        def authenticate
          return session.id if session.present? && session.valid?

          session_id = measure("authentication") do
            response = HTTParty.get(login_endpoint, **httparty_options)
            xml = nori.parse(response.body)
            challenge = xml.dig('SessionInfo', 'Challenge')

            md5 = Digest::MD5.hexdigest("#{challenge}-#{config.password}".encode('UTF-16LE'))

            url = "#{login_endpoint}?response=#{challenge}-#{md5}"
            url = "#{url}&username=#{config.username}" if config.username.present?

            response = HTTParty.get(url, **httparty_options)

            xml = nori.parse(response.body)

            xml.dig('SessionInfo', 'SID')
          end

          self.session = Session.new(session_id)

          session_id
        end

        def login_endpoint
          "#{config.endpoint}/login_sid.lua"
        end

        def httparty_options
          {
            verify: config.verify_ssl,
            logger: config.logger
          }.compact
        end

        def nori
          @nori ||= Nori.new
        end

        def measure(identifier, &block)
          time_start = Time.now
          result = block.call
          time_elapsed = (Time.now - time_start).to_f.round(3)
          config.logger.debug("Request `#{identifier}` took #{time_elapsed} seconds")
          result
        end
      end

      delegate :get, :parse, to: :class
    end
  end
end
