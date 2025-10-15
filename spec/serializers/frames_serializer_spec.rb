# frozen_string_literal: true
require "rails_helper"

RSpec.describe FrameSerializer do
  context "when frame has no circles" do
    it "serializes extremal circles as nil and counts zero" do
      frame   = create(:frame, center_x: 0, center_y: 0, width: 40, height: 40)
      payload = described_class.new(frame).as_json

      expect(payload).to include(
        id: frame.id,
        center_x: frame.center_x.to_f,
        center_y: frame.center_y.to_f,
        width:    frame.width.to_f,
        height:   frame.height.to_f,
        circles_count: 0
      )
      %i[topmost_circle bottommost_circle leftmost_circle rightmost_circle].each do |k|
        expect(payload[k]).to be_nil
      end
      expect(payload[:circles]).to eq([])
    end
  end

  context "when frame has circles" do
    it "serializes circles and extremal ones using CircleSerializer schema" do
      frame = create(:frame, center_x: 0, center_y: 0, width: 100, height: 100)
      create(:circle, frame:, center_x: 40,  center_y:  0,  diameter: 10)
      create(:circle, frame:, center_x: -40, center_y:  0,  diameter: 10)
      create(:circle, frame:, center_x: 0,   center_y:  40, diameter: 10)
      create(:circle, frame:, center_x: 0,   center_y: -40, diameter: 10)

      payload = described_class.new(frame).as_json

      expect(payload[:circles_count]).to eq(4)
      expect(payload[:rightmost_circle]).to include(center_x: 40.0, frame_id: frame.id)
      expect(payload[:leftmost_circle]).to  include(center_x: -40.0, frame_id: frame.id)
      expect(payload[:topmost_circle]).to   include(center_y: 40.0, frame_id: frame.id)
      expect(payload[:bottommost_circle]).to include(center_y: -40.0, frame_id: frame.id)

      expect(payload[:circles]).to all(include(:id, :frame_id, :center_x, :center_y, :diameter))
    end
  end
end
