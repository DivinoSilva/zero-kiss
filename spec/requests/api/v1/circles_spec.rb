# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Circles API", type: :request do
  def json = JSON.parse(response.body)

  let!(:frame) { create(:frame, center_x: 0, center_y: 0, width: 20, height: 20) }

  describe "POST /api/v1/frames/:frame_id/circles" do
    it "creates (201) when it fits and does not touch others" do
      post "/api/v1/frames/#{frame.id}/circles",
           params: { circle: { center_x: 0, center_y: 0, diameter: 4 } }
      expect(response).to have_http_status(:created)
      expect(json).to include("id", "frame_id", "center_x", "center_y", "diameter")
    end

    it "returns 422 when the circle would touch another" do
      create(:circle, frame:, center_x: 0, center_y: 0, diameter: 4)
      post "/api/v1/frames/#{frame.id}/circles",
           params: { circle: { center_x: 2, center_y: 0, diameter: 4 } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key("errors")
    end

    it "returns 422 when the circle exceeds the frame bounds" do
      post "/api/v1/frames/#{frame.id}/circles",
           params: { circle: { center_x: 11, center_y: 0, diameter: 20 } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key("errors")
    end
  end

  describe "PUT /api/v1/circles/:id" do
    it "updates and returns 200" do
      circle = create(:circle, frame:, center_x: 0, center_y: 0, diameter: 4)
      put "/api/v1/circles/#{circle.id}", params: { circle: { center_x: 1 } }
      expect(response).to have_http_status(:ok)
      expect(json["center_x"]).to eq(1.0)
    end

    it "returns 422 if update breaks rules" do
      circle = create(:circle, frame:, center_x: 0, center_y: 0, diameter: 4)
      put "/api/v1/circles/#{circle.id}", params: { circle: { diameter: 0 } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key("errors")
    end

    it "returns 404 for unknown id" do
      put "/api/v1/circles/999_999", params: { circle: { center_x: 1 } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/circles/:id" do
    it "deletes and returns 204" do
      circle = create(:circle, frame:, center_x: 0, center_y: 0, diameter: 4)
      delete "/api/v1/circles/#{circle.id}"
      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for unknown id" do
      delete "/api/v1/circles/999_999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/circles (search)" do
    before do
      create(:circle, frame:, center_x: 0, center_y: 0, diameter: 2)
      create(:circle, frame:, center_x: 5, center_y: 0, diameter: 2)
    end

    it "returns by radius with correct math (no XOR bug)" do
      get "/api/v1/circles", params: { center_x: 0, center_y: 0, radius: 3 }
      expect(response).to have_http_status(:ok)
      ids = json.map { |h| h["id"] }
      expect(ids.length).to eq(1)
    end

    it "supports pagination" do
      get "/api/v1/circles", params: { per_page: 1, page: 2 }
      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(1)
    end
  end
end
