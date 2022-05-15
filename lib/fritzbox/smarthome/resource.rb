module Fritzbox
  module Smarthome
    class Resource
      class << self
        # @param params [Hash] key/value pairs that will be appended to the switchcmd query string
        def get(command:, ain: nil, param: nil, **params)
          url = "#{config.endpoint}/webservices/homeautoswitch.lua?switchcmd=#{command}&sid=#{authenticate}"
          url = "#{url}&ain=#{ain}"     if ain.present?
          url = "#{url}&param=#{param}" if param.present?

          params.each_with_object(url) do |(key, value)|
            url = "#{url}&#{key}=#{value}"
          end

          config.logger.debug(url)

          HTTParty.get(url, **httparty_options)
        end

        private

        delegate :config, to: Smarthome

        def authenticate
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
      end
    end
  end
end
