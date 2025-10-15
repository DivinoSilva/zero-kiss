# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      def token
        unless passphrase_valid? && date_valid?
          return render json: { error: "unauthorized" }, status: :unauthorized
        end

        token = JsonWebToken.encode({})
        exp   = JsonWebToken.default_ttl + Time.now.to_i
        render json: { token:, exp: }, status: :ok
      end

      private

      def passphrase_valid?
        request.headers["X-Passphrase"].to_s == ENV["YOU_SHOW_NOT_PASS"].to_s
      end

      def date_valid?
        request.headers["X-Date"].to_s == Date.current.to_s
      end
    end
  end
end
