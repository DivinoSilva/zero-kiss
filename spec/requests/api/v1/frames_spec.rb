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

    context "explicit empty circles_attributes" do
      it "creates a frame with zero circles (201)" do
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

    context "with nested circles (valid set)" do
      it "creates frame and circles atomically (201)" do
        expect {
          post path, params: {
            frame: {
              center_x: 0, center_y: 0, width: 100, height: 100,
              circles_attributes: [
                { center_x: -20, center_y: 0,  diameter: 10 },
                { center_x:  20, center_y: 0,  diameter: 10 }
              ]
            }
          }
        }.to change(Frame, :count).by(1).and change(Circle, :count).by(2)

        expect(response).to have_http_status(:created)
        expect(json["circles_count"]).to eq(2)
      end
    end

    context "with nested circles (invalid set)" do
      it "returns 422 and persists nothing (atomic)" do
        expect {
          post path, params: {
            frame: {
              center_x: 0, center_y: 0, width: 30, height: 30,
              circles_attributes: [
                { center_x: 0, center_y: 0, diameter: 10 },
                { center_x: 5, center_y: 0, diameter: 10 }
              ]
            }
          }
        }.to change(Frame, :count).by(0).and change(Circle, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to have_key("errors")
      end
    end

    context "frame separation rule - edge touch" do
      it "returns 422" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 10, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "frame separation rule - corner touch" do
      it "returns 422" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 10, center_y: 10, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "frame separation rule - overlap" do
      it "returns 422" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 4, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when there is minimum separation (epsilon = 0.001)" do
      it "returns 201" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 10.001, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:created)
      end
    end

    context "strict separation" do
      it "returns 201" do
        create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        post path, params: { frame: { center_x: 11, center_y: 0, width: 10, height: 10 } }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /api/v1/frames/:id" do
    context "when the frame exists" do
      let!(:frame) { create(:frame, center_x: 0, center_y: 0, width: 100, height: 100) }

      it "returns 200 with payload and extremal circles" do
        create(:circle, frame:, center_x:  40, center_y:  0,  diameter: 10)
        create(:circle, frame:, center_x: -40, center_y:  0,  diameter: 10)
        create(:circle, frame:, center_x:   0, center_y:  40, diameter: 10)
        create(:circle, frame:, center_x:   0, center_y: -40, diameter: 10)

        get "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:ok)
        expect(json["circles_count"]).to eq(4)
        expect(json["rightmost_circle"]).to include("center_x" => 40.0)
        expect(json["leftmost_circle"]).to  include("center_x" => -40.0)
        expect(json["topmost_circle"]).to   include("center_y" => 40.0)
        expect(json["bottommost_circle"]).to include("center_y" => -40.0)
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
    context "when the frame has circles" do
      it "returns 422 with errors" do
        frame = create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        create(:circle, frame:, center_x: 0, center_y: 0, diameter: 2)
        delete "/api/v1/frames/#{frame.id}"
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json).to have_key("errors")
      end
    end

    context "when the frame exists and has no circles" do
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
