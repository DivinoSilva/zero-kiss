require "swagger_helper"

RSpec.describe "Circles API", type: :request do
  path "/api/v1/frames/{frame_id}/circles" do
    post "Create a circle in a frame" do
      operationId "createCircle"
      tags "Circles"
      consumes "application/json"
      produces "application/json"

      parameter name: :frame_id, in: :path, type: :integer, description: "Frame ID"
      parameter name: :circle, in: :body, schema: { "$ref" => "#/components/schemas/CircleCreatePayload/properties/circle" }

      let(:frame)    { create(:frame, center_x: 0, center_y: 0, width: 40, height: 40) }
      let(:frame_id) { frame.id }

      response "201", "Circle created" do
        schema "$ref" => "#/components/schemas/Circle"
        let(:circle) { { center_x: 0, center_y: 0, diameter: 6 } }
        run_test!
      end

      response "422", "Validation error" do
        schema "$ref" => "#/components/schemas/Errors422"
        let(:circle) { { center_x: 21, center_y: 0, diameter: 40 } }
        run_test!
      end

      response "404", "Frame not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:frame_id) { 999_999 }
        let(:circle)   { { center_x: 0, center_y: 0, diameter: 6 } }
        run_test!
      end
    end
  end

  path "/api/v1/circles/{id}" do
    put "Update a circle" do
      operationId "updateCircle"
      tags "Circles"
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :integer
      parameter name: :circle, in: :body, schema: { "$ref" => "#/components/schemas/CircleUpdatePayload/properties/circle" }

      let(:frame) { create(:frame, center_x: 0, center_y: 0, width: 40, height: 40) }

      response "200", "Circle updated" do
        schema "$ref" => "#/components/schemas/Circle"
        let(:existing) { create(:circle, frame:, center_x: 0, center_y: 0, diameter: 6) }
        let(:id)       { existing.id }
        let(:circle)   { { center_x: 1 } }
        run_test!
      end

      response "422", "Validation error" do
        schema "$ref" => "#/components/schemas/Errors422"
        let(:existing) { create(:circle, frame:, center_x: 0, center_y: 0, diameter: 40) }
        let(:id)       { existing.id }
        let(:circle)   { { center_x: 10.1 } }
        run_test!
      end

      response "404", "Circle not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id)     { 999_999 }
        let(:circle) { { center_x: 1 } }
        run_test!
      end
    end

    delete "Delete a circle" do
      operationId "deleteCircle"
      tags "Circles"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer

      let(:frame) { create(:frame, center_x: 0, center_y: 0, width: 40, height: 40) }

      response "204", "No content" do
        let(:id) { create(:circle, frame:, center_x: 0, center_y: 0, diameter: 6).id }
        run_test!
      end

      response "404", "Circle not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        run_test!
      end
    end
  end

  path "/api/v1/circles" do
    get "Search circles" do
      operationId "searchCircles"
      tags "Circles"
      produces "application/json"

      parameter name: :center_x, in: :query, schema: { type: :number }
      parameter name: :center_y, in: :query, schema: { type: :number }
      parameter name: :radius,   in: :query, schema: { type: :number }
      parameter name: :frame_id, in: :query, schema: { type: :integer }
      parameter name: :page,     in: :query, schema: { type: :integer, default: 1, minimum: 1 }
      parameter name: :per_page, in: :query, schema: { type: :integer, default: 50, minimum: 1, maximum: 200 }

      let(:center_x) { nil }
      let(:center_y) { nil }
      let(:radius)   { nil }
      let(:frame_id) { nil }
      let(:page)     { nil }
      let(:per_page) { nil }

      response "200", "OK" do
        schema type: :array, items: { "$ref" => "#/components/schemas/Circle" }
        run_test!
      end
    end
  end
end
