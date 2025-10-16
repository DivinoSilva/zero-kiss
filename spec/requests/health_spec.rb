# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Health", swagger_doc: "v1/swagger.yaml" do
  path "/healthz" do
    get("ok") do
      tags "Health"
      produces "application/json"
      description "Liveness/Readiness probe. No authentication required."
      parameter name: "Authorization",
                in: :header,
                required: false,
                schema: { type: :string },
                description: "Not required for this endpoint"

      let(:Authorization) { nil }

      response(200, "ok") do
        run_test!
      end
    end
  end
end
