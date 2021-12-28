# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'

module Mtn
  module Pesa
    class Example
      STAGING_URL = "https://sandbox.momodeveloper.mtn.com/collection/token/".freeze
      PRODUCTION_URL = "https://momodeveloper.mtn.com/collection/token/".freeze

      attr_reader :param1, :param2, :param3, :param4, :param5, :param6

      def self.call(param1:, param2:, param3:, param4:, param5:, param6:)
        new(param1, param2, param3, param4, param5, param6).call
      end
  
      def initialize(param1, param2, param3, param4, param5, param6)
        @param1 = param1
        @param2 = param2
        @param3 = param3
        @param4 = param4
        @param5 = param5
        @param6 = param6
      end
  
      def call
        url = URI("#{env_url}/merchant/v1/payments/")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = 'application/json'
        request["Authorization"] = "Bearer #{token}"
        request["X-Country"] = param2
        request["X-Currency"] = param3
        request.body = JSON.dump(body)

        response = http.request(request)
        parsed_response = JSON.parse(response.read_body)
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

      def token
        Mtn::Pesa::Authorization.call.result.access_token
      end

      def body
        {}
      end
    end
  end
end
