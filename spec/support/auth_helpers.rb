# frozen_string_literal: true
require "jwt"

module AuthHelpers
  def auth_headers
    secret = ENV.fetch("JWT_SECRET", "secret")
    iss    = ENV.fetch("JWT_ISS", "zerokiss")
    aud    = ENV.fetch("JWT_AUD", "zerokiss-clients")
    ttl    = ENV.fetch("JWT_TTL_SECONDS", "3600").to_i

    now = Time.now.to_i
    payload = {
      sub: "spec-user",
      iat: now,
      exp: now + ttl,
      iss: iss,
      aud: aud
    }

    token = JWT.encode(payload, secret, "HS256")
    { "Authorization" => "Bearer #{token}" }
  end
end
