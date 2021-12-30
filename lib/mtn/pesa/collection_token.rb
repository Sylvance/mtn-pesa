# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'

module Mtn
  module Pesa
    class CollectionToken
      STAGING_URL = "https://sandbox.momodeveloper.mtn.com".freeze
      PRODUCTION_URL = "https://momodeveloper.mtn.com".freeze

      def initialize; end

      def self.call
        url = URI("#{env_url}/collection/token/")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = 'application/json'
        request["Authorization"] = 'application/json'
        request["Ocp-Apim-Subscription-Key"] = Mtn::Pesa.configuration.ocp_apim_subscription_key
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
        {}
      end
    end
  end
end
