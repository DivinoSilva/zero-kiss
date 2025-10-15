# frozen_string_literal: true

require "rails_helper"

RSpec.describe CircleNoTouchOverlapValidator do
  let(:frame) { create(:frame, center_x: 0, center_y: 0, width: 60, height: 60) }

  it "is valid when circles are strictly separated" do
    create(:circle, frame:, center_x: 0,  center_y: 0, diameter: 10)
    circle = build(:circle,  frame:, center_x: 11, center_y: 0, diameter: 10)
    expect(circle).to be_valid
  end

  it "is invalid when circles just touch" do
    create(:circle, frame:, center_x: 0,  center_y: 0, diameter: 10)
    circle = build(:circle,  frame:, center_x: 10, center_y: 0, diameter: 10)
    expect(circle).to be_invalid
    expect(circle.errors[:base]).to include("circles cannot touch or overlap within the same frame")
  end

  it "is invalid when circles overlap" do
    create(:circle, frame:, center_x: 0,  center_y: 0, diameter: 10)
    circle = build(:circle,  frame:, center_x: 8,  center_y: 0, diameter: 10)
    expect(circle).to be_invalid
  end
end
