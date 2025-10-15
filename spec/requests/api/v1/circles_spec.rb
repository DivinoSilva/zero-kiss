# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Circles API", type: :request do
  def json = JSON.parse(response.body)

  let!(:frame) { create(:frame, center_x: 0, center_y: 0, width: 40, height: 40) }

  describe "POST /api/v1/frames/:frame_id/circles" do
    it "creates (201) when it fits and does not touch others" do
      post "/api/v1/frames/#{frame.id}/circles",
           params: { circle: { center_x: 0, center_y: 0, diameter: 6 } }
      expect(response).to have_http_status(:created)
      expect(json).to include("id", "frame_id", "center_x", "center_y", "diameter")
    end

    it "returns 422 when the circle would touch another" do
      create(:circle, frame:, center_x: 0, center_y: 0, diameter: 6)
      post "/api/v1/frames/#{frame.id}/circles",
           params: { circle: { center_x: 3, center_y: 0, diameter: 6 } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key("errors")
    end

    it "returns 422 when the circle exceeds the frame bounds" do
      post "/api/v1/frames/#{frame.id}/circles",
           params: { circle: { center_x: 20.1, center_y: 0, diameter: 40 } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key("errors")
    end

    it "returns 404 when frame does not exist" do
      post "/api/v1/frames/999_999/circles",
           params: { circle: { center_x: 0, center_y: 0, diameter: 6 } }
      expect(response).to have_http_status(:not_found)
      expect(json["error"]).to eq("not found")
    end
  end

  describe "PUT /api/v1/circles/:id" do
    it "updates and returns 200" do
      circle = create(:circle, frame:, center_x: 0, center_y: 0, diameter: 6)
      put "/api/v1/circles/#{circle.id}", params: { circle: { center_x: 1 } }
      expect(response).to have_http_status(:ok)
      expect(json["center_x"]).to eq(1.0)
    end

    it "returns 422 if update would move circle outside the frame" do
      circle = create(:circle, frame:, center_x: 0, center_y: 0, diameter: 40)
      put "/api/v1/circles/#{circle.id}", params: { circle: { center_x: 10.1 } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to have_key("errors")
    end

    it "returns 422 if update would make circles touch/overlap" do
      a = create(:circle, frame:, center_x: 0,  center_y: 0, diameter: 6)
      b = create(:circle, frame:, center_x: 10, center_y: 0, diameter: 6)
      put "/api/v1/circles/#{b.id}", params: { circle: { center_x: 3 } }
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
      circle = create(:circle, frame:, center_x: 0, center_y: 0, diameter: 6)
      delete "/api/v1/circles/#{circle.id}"
      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for unknown id" do
      delete "/api/v1/circles/999_999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/circles (search + filter + pagination)" do
    before do
      create(:circle, frame:, center_x: 0, center_y: 0, diameter: 2)
      create(:circle, frame:, center_x: 5, center_y: 0, diameter: 2)
    end

    it "filters by frame_id" do
      get "/api/v1/circles", params: { frame_id: frame.id }
      expect(response).to have_http_status(:ok)
      frames = json.map { |h| h["frame_id"] }.uniq
      expect(frames).to eq([frame.id])
    end

    it "radius query returns only circles strictly inside (r - d/2)" do
      get "/api/v1/circles", params: { center_x: 0, center_y: 0, radius: 3 }
      expect(response).to have_http_status(:ok)
      ids = json.map { |h| h["id"] }
      expect(ids.size).to eq(1)
    end

    it "returns empty when radius < diameter/2" do
      get "/api/v1/circles", params: { center_x: 0, center_y: 0, radius: 0.5 }
      expect(response).to have_http_status(:ok)
      expect(json).to eq([])
    end

    it "respects per_page parameter" do
      get "/api/v1/circles", params: { per_page: 1, page: 1 }
      expect(response).to have_http_status(:ok)
      expect(json.length).to eq(1)
    end

    it "clamps per_page to the maximum (200)" do
      205.times { |i| create(:circle, frame:, center_x: -15 + i * 0.06, center_y: 0, diameter: 0.05) }
      get "/api/v1/circles", params: { per_page: 1_000, page: 1 }
      expect(response).to have_http_status(:ok)
      expect(json.length).to be <= 200
    end
  end
end
