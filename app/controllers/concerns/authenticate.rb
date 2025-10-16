# frozen_string_literal: true

module Authenticate
  extend ActiveSupport::Concern

  class Unauthorized < StandardError; end

  included do
    rescue_from Unauthorized do |e|
      render json: { error: e.message.presence || "unauthorized" }, status: :unauthorized
    end
  end

  private

  def require_jwt!
    auth  = request.authorization.to_s
    token = auth.start_with?("Bearer ") ? auth.split(" ", 2).last : nil
    raise Unauthorized, "unauthorized" unless token
    ::JsonWebToken.decode(token)
    true
  rescue JWT::DecodeError => e
    raise Unauthorized, e.message
  end
end

