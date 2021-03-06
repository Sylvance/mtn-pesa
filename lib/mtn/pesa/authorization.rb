# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'

module Airtel
  module Pesa
    class Authorization
      STAGING_URL = "https://sandbox.momodeveloper.mtn.com".freeze
      PRODUCTION_URL = "https://momodeveloper.mtn.com".freeze

      def initialize; end

      def self.call
        url = URI("#{env_url}/auth/oauth2/token")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = 'application/json'
        request.body = JSON.dump(body)

        response = http.request(request)
        parsed_body = JSON.parse(response.read_body)

        result = Airtel::Pesa.to_recursive_ostruct(parsed_response)
        OpenStruct.new(result: result, error: nil)
      rescue JSON::ParserError => error
        OpenStruct.new(result: nil, error: error)
      end

      private

      def env_url
        return STAGING_URL Airtel::Pesa.configuration.env == 'staging'
        return PRODUCTION_URL Airtel::Pesa.configuration.env == 'production'
      end

      def body
        {
          "api_user": Airtel::Pesa.configuration.api_user,
          "api_key": Airtel::Pesa.configuration.api_key
        }
      end
    end
  end
end
