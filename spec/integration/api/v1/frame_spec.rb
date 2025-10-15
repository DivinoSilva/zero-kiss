# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Frames API", type: :request do
  def json = JSON.parse(response.body)

  describe "POST /api/v1/frames" do
    let(:path) { "/api/v1/frames" }

    context "without circles_attributes" do
      it "creates a frame (201) with no circles" do
        expect {
          post path, params: { frame: { center_x: 0, center_y: 0, width: 100, height: 100 } }
        }.to change(Frame, :count).by(1).and change(Circle, :count).by(0)

        expect(response).to have_http_status(:created)
        expect(json).to include("id", "center_x", "center_y", "width", "height")
        expect(json["circles"]).to be_an(Array)
        expect(json["circles"]).to be_empty
        expect(json["circles_count"]).to eq(0)
      end
    end

    context "with empty circles_attributes array" do
      it "creates a frame (201) with zero circles" do
        expect {
          post path, params: {
            frame: {
              center_x: 0, center_y: 0, width: 100, height: 100,
              circles_attributes: []
            }
          }
        }.to change(Frame, :count).by(1).and change(Circle, :count).by(0)

        expect(response).to have_http_status(:created)
        expect(json["circles"]).to be_an(Array)
        expect(json["circles"]).to be_empty
        expect(json["circles_count"]).to eq(0)
      end
    end

    it "fails with 422 when any circle is invalid (no-touch rule) and is atomic" do
      expect {
        post path, params: {
          frame: {
            center_x: 0, center_y: 0, width: 100, height: 100,
            circles_attributes: [
              { center_x: 0,  center_y: 0, diameter: 10 },
              { center_x: 10, center_y: 0, diameter: 10 }
            ]
          }
        }
      }.to change(Frame, :count).by(0).and change(Circle, :count).by(0)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key("errors")
    end

    it "fails with 422 when a circle exceeds frame and is atomic" do
      expect {
        post path, params: {
          frame: {
            center_x: 0, center_y: 0, width: 10, height: 10,
            circles_attributes: [
              { center_x: 0,   center_y: 0, diameter: 10 },
              { center_x: 5.1, center_y: 0, diameter: 10 }
            ]
          }
        }
      }.to change(Frame, :count).by(0).and change(Circle, :count).by(0)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key("errors")
    end

    context "when frame payload is invalid" do
      it "returns 422 with errors" do
        expect {
          post path, params: { frame: { center_x: 0, center_y: 0, width: 0, height: -1 } }
        }.to change(Frame, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to have_key("errors")
      end
    end

    context "frame separation rule (no touch / no overlap)" do
      it "returns 422 when new frame would touch another (edge)" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 10, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when new frame would touch another (corner)" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 10, center_y: 10, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when new frame would overlap another" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 4, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 201 when there is strict separation" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 11, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/v1/frames/:id" do
    it "returns circles_count and extremal circles" do
      frame = create(:frame, center_x: 0, center_y: 0, width: 100, height: 100)
      create(:circle, frame:, center_x: 0,   center_y:  0,  diameter: 10)
      create(:circle, frame:, center_x: 40,  center_y:  0,  diameter: 10)
      create(:circle, frame:, center_x: -40, center_y:  0,  diameter: 10)
      create(:circle, frame:, center_x: 0,   center_y:  40, diameter: 10)
      create(:circle, frame:, center_x: 0,   center_y: -40, diameter: 10)

      get "/api/v1/frames/#{frame.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body["circles_count"]).to eq(5)
      expect(body["rightmost_circle"]).to include("center_x" => 40.0)
      expect(body["leftmost_circle"]).to  include("center_x" => -40.0)
      expect(body["topmost_circle"]).to   include("center_y" => 40.0)
      expect(body["bottommost_circle"]).to include("center_y" => -40.0)
    end

    it "returns 404 when frame does not exist" do
      get "/api/v1/frames/999_999"
      expect(response).to have_http_status(:not_found)
      expect(json["error"]).to eq("not found")
    end
  end

  describe "DELETE /api/v1/frames/:id" do
    context "when the frame has circles" do
      it "returns 422 (restrict delete)" do
        frame = create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        create(:circle, frame:, center_x: 0, center_y: 0, diameter: 2)
        delete "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to have_key("errors")
      end
    end

    context "when the frame has no circles" do
      it "deletes and returns 204" do
        frame = create(:frame)
        delete "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:no_content)
      end
    end

    it "returns 404 when frame does not exist" do
      delete "/api/v1/frames/999_999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
