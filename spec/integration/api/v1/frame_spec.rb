# frozen_string_literal: true
require "swagger_helper"

RSpec.describe "Frames API", type: :request do
  path "/api/v1/frames" do
    post "Create a frame" do
      operationId "createFrame"
      tags "Frames"
      consumes "application/json"
      produces "application/json"

      parameter name: :frame, in: :body, schema: { "$ref" => "#/components/schemas/FrameCreatePayload/properties/frame" }

      response "201", "Frame created" do
        schema "$ref" => "#/components/schemas/FrameShow"
        let(:frame) { attributes_for(:frame) }
        run_test!
      end

      response "422", "Validation error" do
        schema "$ref" => "#/components/schemas/Errors422"
        let(:frame) { { center_x: 0, center_y: 0, width: 0, height: -1 } }
        run_test!
      end
    end
  end

  path "/api/v1/frames/{id}" do
    get "Show a frame" do
      operationId "showFrame"
      tags "Frames"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer

      response "200", "OK" do
        schema "$ref" => "#/components/schemas/FrameShow"
        let(:id) { create(:frame).id }
        run_test!
      end

      response "404", "Not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        run_test!
      end
    end

    delete "Delete a frame" do
      operationId "deleteFrame"
      tags "Frames"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer

      response "204", "No content" do
        let(:id) { create(:frame).id }
        run_test!
      end

      response "422", "Cannot delete frame with circles" do
        schema "$ref" => "#/components/schemas/Errors422"
        let(:frame_rec) { create(:frame, center_x: 0, center_y: 0, width: 40, height: 40) }
        let(:id)        { frame_rec.id }
        before { create(:circle, frame: frame_rec, center_x: 0, center_y: 0, diameter: 6) }
        run_test!
      end

      response "404", "Not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        run_test!
      end
    end
  end
end
