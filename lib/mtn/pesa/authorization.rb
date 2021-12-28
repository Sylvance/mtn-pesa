# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'

module Mtn
  module Pesa
    class Authorization
      STAGING_URL = "https://sandbox.momodeveloper.mtn.com/collection/token/".freeze
      PRODUCTION_URL = "https://momodeveloper.mtn.com/collection/token/".freeze

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

        result = Mtn::Pesa.to_recursive_ostruct(parsed_response)
        OpenStruct.new(result: result, error: nil)
      rescue JSON::ParserError => error
        OpenStruct.new(result: nil, error: error)
      end

      private

      def env_url
        return STAGING_URL Mtn::Pesa.configuration.env == 'staging'
        return PRODUCTION_URL Mtn::Pesa.configuration.env == 'production'
      end

      def body
        {
          "client_id": Mtn::Pesa.configuration.client_id,
          "client_secret": Mtn::Pesa.configuration.client_secret,
          "grant_type": "client_credentials"
        }
      end
    end
  end
end
