# frozen_string_literal: true

module AuthHelpers
  def auth_headers
    passphrase = ENV["YOU_SHOW_NOT_PASS"] || raise("YOU_SHOW_NOT_PASS not set")
    date_str   = Date.current.to_s

    post "/api/v1/auth/token", headers: {
      "X-Passphrase" => passphrase,
      "X-Date"       => date_str
    }

    unless response.success?
      raise "Cannot obtain auth token (status=#{response.status} body=#{response.body})"
    end

    token = JSON.parse(response.body)["token"] or raise("Token missing in /auth/token response")
    { "Authorization" => "Bearer #{token}" }
  end
end
