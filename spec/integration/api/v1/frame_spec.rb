# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Frames", type: :request do
  path "/api/v1/frames" do
    post("create frame") do
      tags "Frames"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: { "$ref": "#/components/schemas/FrameCreatePayload" }

      response(201, "created") do
        let(:payload) { { frame: attributes_for(:frame) } }
        schema "$ref": "#/components/schemas/Frame"
        run_test!
      end

      response(422, "unprocessable entity") do
        let(:payload) { { frame: { center_x: 0, center_y: 0, width: 0, height: -1 } } }
        schema "$ref": "#/components/schemas/Errors422"
        run_test!
      end
    end
  end

  path "/api/v1/frames/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Frame ID"

    get("show frame") do
      tags "Frames"
      produces "application/json"

      response(200, "ok") do
        let(:id) { create(:frame).id }
        schema "$ref": "#/components/schemas/Frame"
        run_test!
      end

      response(404, "not found") do
        let(:id) { 999_999 }
        schema "$ref": "#/components/schemas/Error"
        run_test!
      end
    end

    delete("delete frame") do
      tags "Frames"

      response(204, "no content") do
        let(:id) { create(:frame).id }
        run_test!
      end

      response(404, "not found") do
        let(:id) { 999_999 }
        schema "$ref": "#/components/schemas/Error"
        run_test!
      end
    end
  end
end
