# frozen_string_literal: true
require "rails_helper"

RSpec.describe CircleSerializer do
  it "serializes numeric fields as floats" do
    frame  = create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
    circle = create(:circle, frame:, center_x: 1.234, center_y: 2.345, diameter: 3.456)
    json = described_class.new(circle).as_json

    expect(json[:center_x]).to be_a(Float)
    expect(json[:center_y]).to be_a(Float)
    expect(json[:diameter]).to be_a(Float)
  end
end
