# frozen_string_literal: true
require "swagger_helper"

RSpec.describe "Circles API", type: :request do
  path "/api/v1/frames/{frame_id}/circles" do
    post "Create a circle in a frame" do
      operationId "createCircle"
      tags "Circles"
      consumes "application/json"
      produces "application/json"

      parameter name: :frame_id, in: :path, type: :integer, description: "Frame ID"
      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/CircleCreatePayload" }

      response "201", "Circle created" do
        schema "$ref" => "#/components/schemas/Circle"
        let(:frame_id) { Frame.create!(center_x: 0, center_y: 0, width: 10, height: 10).id }
        let(:payload)  { { circle: { center_x: 0, center_y: 0, diameter: 2 } } }
        examples "application/json" => {
          id: 1, frame_id: 1, center_x: 0.0, center_y: 0.0, diameter: 2.0
        }
        run_test!
      end

      response "422", "Validation error" do
        schema "$ref" => "#/components/schemas/Errors422"
        let(:frame_id) { Frame.create!(center_x: 0, center_y: 0, width: 10, height: 10).id }
        let(:payload)  { { circle: { center_x: 10, center_y: 0, diameter: 10 } } }
        examples "application/json" => {
          errors: { base: ["circle must be fully inside the frame"] }
        }
        run_test!
      end

      response "404", "Frame not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:frame_id) { 999_999 }
        let(:payload)  { { circle: { center_x: 0, center_y: 0, diameter: 2 } } }
        examples "application/json" => { error: "not found" }
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

      parameter name: :id, in: :path, type: :integer, description: "Circle ID"
      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/CircleUpdatePayload" }

      response "200", "Circle updated" do
        schema "$ref" => "#/components/schemas/Circle"
        let(:circle) do
          Frame.create!(center_x: 0, center_y: 0, width: 10, height: 10)
               .circles.create!(center_x: 0, center_y: 0, diameter: 2)
        end
        let(:id)      { circle.id }
        let(:payload) { { circle: { center_x: 1 } } }
        examples "application/json" => {
          id: 1, frame_id: 1, center_x: 1.0, center_y: 0.0, diameter: 2.0
        }
        run_test!
      end

      response "422", "Validation error" do
        schema "$ref" => "#/components/schemas/Errors422"
        let(:circle) do
          Frame.create!(center_x: 0, center_y: 0, width: 10, height: 10)
               .circles.create!(center_x: 0, center_y: 0, diameter: 2)
        end
        let(:id)      { circle.id }
        let(:payload) { { circle: { diameter: 0 } } }
        examples "application/json" => {
          errors: { diameter: ["must be greater than 0"] }
        }
        run_test!
      end

      response "404", "Circle not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id)      { 999_999 }
        let(:payload) { { circle: { center_x: 1 } } }
        examples "application/json" => { error: "not found" }
        run_test!
      end
    end

    delete "Delete a circle" do
      operationId "deleteCircle"
      tags "Circles"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Circle ID"

      response "204", "No content" do
        let(:id) do
          Frame.create!(center_x: 0, center_y: 0, width: 10, height: 10)
               .circles.create!(center_x: 0, center_y: 0, diameter: 2).id
        end
        run_test!
      end

      response "404", "Circle not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        examples "application/json" => { error: "not found" }
        run_test!
      end
    end
  end

  path "/api/v1/circles" do
    get "Search circles by radius and optional frame_id" do
      operationId "searchCircles"
      tags "Circles"
      produces "application/json"

      parameter name: :center_x, in: :query, schema: { type: :number }, description: "Search center X"
      parameter name: :center_y, in: :query, schema: { type: :number }, description: "Search center Y"
      parameter name: :radius,   in: :query, schema: { type: :number }, description: "Search radius"
      parameter name: :frame_id, in: :query, schema: { type: :integer }, description: "Filter by frame"
      parameter name: :page,     in: :query, schema: { type: :integer, default: 1, minimum: 1 }, description: "Page number"
      parameter name: :per_page, in: :query, schema: { type: :integer, default: 50, minimum: 1, maximum: 200 }, description: "Items per page"

      response "200", "OK" do
        schema type: :array, items: { "$ref" => "#/components/schemas/Circle" }
        examples "application/json" => [
          { id: 1, frame_id: 1, center_x: 0.0, center_y: 0.0, diameter: 2.0 }
        ]
        run_test!
      end
    end
  end
end
