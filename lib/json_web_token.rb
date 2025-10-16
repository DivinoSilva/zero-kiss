# frozen_string_literal: true
require "jwt"

class JsonWebToken
  ALGO = "HS256".freeze

  def self.encode(payload, exp: default_ttl, iss: default_iss, aud: default_aud, secret: default_secret)
    now = Time.now.to_i
    payload = payload.dup
    payload[:iat] = now
    payload[:exp] = now + exp
    payload[:iss] = iss
    payload[:aud] = aud
    JWT.encode(payload, secret, ALGO)
  end

  def self.decode(token, iss: default_iss, aud: default_aud, secret: default_secret)
    decoded, = JWT.decode(
      token,
      secret,
      true,
      {
        algorithm: ALGO,
        iss:, verify_iss: true,
        aud:, verify_aud: true
      }
    )
    decoded.with_indifferent_access
  end

  def self.default_secret = ENV.fetch("JWT_SECRET")
  def self.default_iss    = ENV.fetch("JWT_ISS", "zerokiss")
  def self.default_aud    = ENV.fetch("JWT_AUD", "zerokiss-clients")
  def self.default_ttl    = Integer(ENV.fetch("JWT_TTL_SECONDS", "60"))
end
