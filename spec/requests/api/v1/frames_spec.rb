# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Frames API", type: :request do
  def json = JSON.parse(response.body)

  describe "POST /api/v1/frames" do
    let(:path) { "/api/v1/frames" }

    context "when payload is valid" do
      it "creates and returns 201" do
        post path, params: { frame: { center_x: 10, center_y: 10, width: 20, height: 30 } }
        expect(response).to have_http_status(:created)
        expect(json).to include("id", "center_x", "center_y", "width", "height")
      end
    end

    context "when payload is invalid" do
      it "returns 422 with errors" do
        post path, params: { frame: { center_x: 0, center_y: 0, width: 0, height: -1 } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to have_key("errors")
      end
    end

    context "when the new frame would touch another (edge)" do
      it "returns 422" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 10, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the new frame would touch another (corner)" do
      it "returns 422" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 10, center_y: 10, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the new frame would overlap another" do
      it "returns 422" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 4, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when there is strict separation" do
      it "returns 201" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 11, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/v1/frames/:id" do
    context "when the frame exists" do
      let!(:frame) { create(:frame) }

      it "returns 200 with the frame payload" do
        get "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(frame.id)
      end
    end

    context "when the frame does not exist" do
      it "returns 404 with error" do
        get "/api/v1/frames/999_999"
        expect(response).to have_http_status(:not_found)
        expect(json["error"]).to eq("not found")
      end
    end
  end

  describe "DELETE /api/v1/frames/:id" do
    context "when the frame exists" do
      let!(:frame) { create(:frame) }

      it "deletes and returns 204" do
        delete "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when the frame does not exist" do
      it "returns 404" do
        delete "/api/v1/frames/999_999"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
