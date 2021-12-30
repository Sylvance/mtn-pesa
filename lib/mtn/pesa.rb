# frozen_string_literal: true

require_relative "pesa/collection_token"
require_relative "pesa/version"

module Mtn
  module Pesa
    class Error < StandardError; end

    def self.configuration
      @configuration ||= OpenStruct.new(
        api_user: nil,
        api_key: nil,
        enviroment: nil
      )
    end

    def self.configure
      yield(configuration)
    end

    def to_recursive_ostruct(hash)
      result = hash.each_with_object({}) do |(key, val), memo|
          memo[key] = val.is_a?(Hash) ? to_recursive_ostruct(val) : val
      end

      OpenStruct.new(result)
    end
  end
end
