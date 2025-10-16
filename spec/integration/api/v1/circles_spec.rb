# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Circles API", swagger_doc: "v1/swagger.yaml" do
  path "/api/v1/frames/{frame_id}/circles" do
    post("Circle created") do
      tags "Circles"
      consumes "application/json"
      produces "application/json"

      parameter name: :frame_id, in: :path, type: :integer, required: true
      parameter name: "Authorization", in: :header, schema: { type: :string }, required: true

      parameter name: :circle, in: :body, schema: {
        type: :object,
        required: %w[center_x center_y diameter],
        properties: {
          center_x: { type: :number },
          center_y: { type: :number },
          diameter: { type: :number }
        }
      }

      response(201, "Circle created") do
        let(:frame_id) { create(:frame, center_x: 0, center_y: 0, width: 40, height: 40).id }
        let(:Authorization) { auth_headers["Authorization"] }
        let(:circle) { { center_x: 0, center_y: 0, diameter: 6 } }
        run_test!
      end

      response(404, "not found") do
        let(:frame_id) { 999_999 }
        let(:Authorization) { auth_headers["Authorization"] }
        let(:circle) { { center_x: 0, center_y: 0, diameter: 6 } }
        run_test!
      end

      response(422, "unprocessable entity") do
        let(:frame_id) { create(:frame, center_x: 0, center_y: 0, width: 40, height: 40).id }
        let(:Authorization) { auth_headers["Authorization"] }
        let(:circle) { { center_x: 25.1, center_y: 0, diameter: 40 } }
        run_test!
      end
    end
  end

  path "/api/v1/circles/{id}" do
    put("Circle updated") do
      tags "Circles"
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: "Authorization", in: :header, schema: { type: :string }, required: true

      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          center_x: { type: :number },
          center_y: { type: :number },
          diameter: { type: :number }
        }
      }

      response(200, "OK") do
        let(:Authorization) { auth_headers["Authorization"] }
        let!(:circle_record) { create(:circle) }
        let(:id) { circle_record.id }
        let(:circle) { { center_x: circle_record.center_x + 1 } }
        run_test!
      end

      response(404, "not found") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:id) { 999_999 }
        let(:circle) { { center_x: 1 } }
        run_test!
      end

      response(422, "unprocessable entity") do
        let(:Authorization) { auth_headers["Authorization"] }
        let!(:circle_record) { create(:circle, diameter: 10) }
        let(:id) { circle_record.id }
        let(:circle) { { diameter: -1 } }
        run_test!
      end
    end

    delete("Circle deleted") do
      tags "Circles"
      produces "application/json"

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: "Authorization", in: :header, schema: { type: :string }, required: true

      response(204, "No content") do
        let(:Authorization) { auth_headers["Authorization"] }
        let!(:circle_record) { create(:circle) }
        let(:id) { circle_record.id }
        run_test!
      end

      response(404, "not found") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:id) { 999_999 }
        run_test!
      end
    end
  end

  path "/api/v1/circles" do
    get("get") do
      tags "Circles"
      produces "application/json"

      parameter name: "Authorization", in: :header, schema: { type: :string }, required: true
      parameter name: :frame_id, in: :query, schema: { type: :integer }
      parameter name: :center_x, in: :query, schema: { type: :number }
      parameter name: :center_y, in: :query, schema: { type: :number }
      parameter name: :radius,   in: :query, schema: { type: :number }
      parameter name: :page,     in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }

      response(200, "OK") do
        let(:Authorization) { auth_headers["Authorization"] }
        let(:frame_id) { nil }
        let(:center_x) { nil }
        let(:center_y) { nil }
        let(:radius)   { nil }
        let(:page)     { nil }
        let(:per_page) { nil }
        run_test!
      end
    end
  end
end
