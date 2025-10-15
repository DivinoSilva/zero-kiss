# frozen_string_literal: true
require "swagger_helper"

RSpec.describe "Frames API", type: :request do
  path "/api/v1/frames" do
    post "Create a frame" do
      operationId "createFrame"
      tags "Frames"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload,
                in: :body,
                schema: { "$ref" => "#/components/schemas/FrameCreatePayload" }

      response "201", "Frame created" do
        schema "$ref" => "#/components/schemas/FrameShow"
        let(:payload) { { frame: attributes_for(:frame) } }
        examples "application/json" => {
          id: 1, center_x: 10.0, center_y: 10.0, width: 20.0, height: 30.0,
          circles_count: 0, circles: []
        }
        run_test!
      end

      response "422", "Validation error" do
        schema "$ref" => "#/components/schemas/Errors422"
        let(:payload) { { frame: { center_x: 0, center_y: 0, width: 0, height: -1 } } }
        examples "application/json" => {
          errors: { width: ["must be greater than 0"], height: ["must be greater than 0"] }
        }
        run_test!
      end
    end
  end

  path "/api/v1/frames/{id}" do
    get "Show a frame" do
      operationId "showFrame"
      tags "Frames"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Frame ID"

      response "200", "OK" do
        schema "$ref" => "#/components/schemas/FrameShow"
        let(:id) { create(:frame).id }
        examples "application/json" => {
          id: 1, center_x: 10.0, center_y: 10.0, width: 20.0, height: 30.0,
          circles_count: 0, circles: [],
          topmost_circle: nil, bottommost_circle: nil, leftmost_circle: nil, rightmost_circle: nil
        }
        run_test!
      end

      response "404", "Not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        examples "application/json" => { error: "not found" }
        run_test!
      end
    end

    delete "Delete a frame" do
      operationId "deleteFrame"
      tags "Frames"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer, description: "Frame ID"

      response "204", "No content" do
        let(:id) { create(:frame).id }
        run_test!
      end

      response "422", "Cannot delete frame with circles" do
        schema "$ref" => "#/components/schemas/Errors422"
        let(:frame) { create(:frame) }
        let(:id)    { frame.id }
        before { create(:circle, frame:) }
        examples "application/json" => {
          errors: { base: ["Cannot delete record because dependent circles exist"] }
        }
        run_test!
      end

      response "404", "Not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        examples "application/json" => { error: "not found" }
        run_test!
      end
    end
  end
end
