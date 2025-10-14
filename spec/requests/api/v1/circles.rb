# frozen_string_literal: true
require "swagger_helper"

RSpec.describe "Circles", type: :request do
  path "/api/v1/frames/{frame_id}/circles" do
    parameter name: :frame_id, in: :path, type: :integer, description: "Frame ID"

    post("create circle") do
      tags "Circles"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: { "$ref": "#/components/schemas/CircleCreatePayload" }

      response(201, "created") do
        let(:frame_id) { create(:frame).id }
        let(:payload)  { { circle: { center_x: 10, center_y: 10, diameter: 6 } } }
        schema "$ref": "#/components/schemas/Circle"
        run_test!
      end

      response(422, "unprocessable entity") do
        description "Validation failed or business rules: circle must fit within frame (may touch), circles in the same frame must not touch or overlap."
        let(:frame_id) { create(:frame, center_x: 0, center_y: 0, width: 10, height: 10).id }
        let(:payload)  { { circle: { center_x: 6, center_y: 0, diameter: 10 } } }
        run_test!
      end
    end
  end

  path "/api/v1/circles/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Circle ID"

    put("update circle") do
      tags "Circles"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: { "$ref": "#/components/schemas/CircleUpdatePayload" }

      response(200, "ok") do
        let(:circle) { create(:circle) }
        let(:id)     { circle.id }
        let(:payload){ { circle: { diameter: circle.diameter.to_f + 0.5 } } }
        schema "$ref": "#/components/schemas/Circle"
        run_test!
      end

      response(422, "unprocessable entity") do
        let(:frame)  { create(:frame, center_x: 0, center_y: 0, width: 10, height: 10) }
        let(:circle) { create(:circle, frame: frame, center_x: 0, center_y: 0, diameter: 6) }
        let(:id)     { circle.id }
        let(:payload){ { circle: { center_x: 5.1 } } } # would exceed frame
        run_test!
      end
    end

    delete("delete circle") do
      tags "Circles"

      response(204, "no content") do
        let(:id) { create(:circle).id }
        run_test!
      end

      response(404, "not found") do
        let(:id) { 999_999 }
        run_test!
      end
    end
  end

  path "/api/v1/circles" do
    get("list circles") do
      tags "Circles"
      produces "application/json"
      parameter name: :center_x, in: :query, schema: { type: :number, format: :float }
      parameter name: :center_y, in: :query, schema: { type: :number, format: :float }
      parameter name: :radius,   in: :query, schema: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true }
      parameter name: :frame_id, in: :query, schema: { type: :integer }

      response(200, "ok") do
        let!(:frame) { create(:frame, center_x: 0, center_y: 0, width: 100, height: 100) }
        let!(:c1)    { create(:circle, frame: frame, center_x: 0, center_y: 0, diameter: 10) }
        let!(:c2)    { create(:circle, frame: frame, center_x: 20, center_y: 0, diameter: 8) }
        run_test!
      end
    end
  end
end
