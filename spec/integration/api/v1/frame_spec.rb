# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Frames API", swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/frames" do
    post("Frame created") do
      tags "Frames"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]
      description "Authentication flow: 1) POST `/api/v1/auth/token` with header `X-Passphrase: <secret>-YYYY-MM-DD`; 2) Click **Authorize** (bearerAuth) and paste the token **without** the `Bearer` prefix; 3) Execute this request."

      parameter name: :frame, in: :body, schema: {
        type: :object,
        required: %w[center_x center_y width height],
        properties: {
          center_x: { type: :number },
          center_y: { type: :number },
          width:    { type: :number },
          height:   { type: :number },
          circles_attributes: {
            type: :array,
            items: {
              type: :object,
              required: %w[center_x center_y diameter],
              properties: {
                center_x: { type: :number },
                center_y: { type: :number },
                diameter: { type: :number }
              }
            }
          }
        }
      }

      response(201, "Frame created") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:frame) { { center_x: 10, center_y: 10, width: 20, height: 30 } }
        run_test!
      end

      response(422, "unprocessable entity") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:frame) { { center_x: 0, center_y: 0, width: 0, height: -1 } }
        run_test!
      end
    end
  end

  path "/api/v1/frames/{id}" do
    get("OK") do
      tags "Frames"
      produces "application/json"
      security [bearerAuth: []]
      description "Requires JWT. Generate at `/api/v1/auth/token` (send `X-Passphrase: <secret>-YYYY-MM-DD`), then click **Authorize** and paste the token **without** `Bearer`."

      parameter name: :id, in: :path, type: :integer, required: true

      response(200, "OK") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:id) { create(:frame).id }
        run_test!
      end

      response(404, "not found") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:id) { 999_999 }
        run_test!
      end
    end

    delete("delete") do
      tags "Frames"
      produces "application/json"
      security [bearerAuth: []]
      description "Requires JWT. Use **Authorize** (bearerAuth) and paste the token **without** `Bearer`."

      parameter name: :id, in: :path, type: :integer, required: true

      response(204, "No content") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:id) { create(:frame).id }
        run_test!
      end

      response(404, "not found") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:id) { 999_999 }
        run_test!
      end
    end
  end
end
