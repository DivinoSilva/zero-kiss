# frozen_string_literal: true
require "swagger_helper"

RSpec.describe "Auth API", swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/auth/token" do
    post("Get JWT token") do
      tags "Auth"
      consumes "application/json"
      produces "application/json"
      description "Send header `X-Passphrase: <secret>-YYYY-MM-DD`. Response body contains `{ token, exp }`. Click Authorize and paste only the token for subsequent requests."
      security []

      parameter name: "X-Passphrase", in: :header,
                schema: { type: :string }, required: true,
                description: "Format: <secret>-YYYY-MM-DD"

      response(200, "OK") do
        let("X-Passphrase") { "#{ENV.fetch('PASSPHRASE', '')}-#{Date.current}" }
        run_test!
      end

      response(401, "unauthorized") do
        let("X-Passphrase") { "invalid-#{Date.current}" }
        run_test!
      end
    end
  end
end
