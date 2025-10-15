# frozen_string_literal: true
require "rails_helper"

RSpec.describe Circle, type: :model do
  describe "validations" do
    it "requires frame, center_x, center_y, and diameter > 0" do
      circle = build(:circle, frame: nil, center_x: nil, center_y: nil, diameter: nil)
      expect(circle).to be_invalid
      expect(circle.errors.attribute_names).to include(:frame, :center_x, :center_y, :diameter)

      circle_with_non_positive_diameter = build(:circle, diameter: 0)
      expect(circle_with_non_positive_diameter).to be_invalid
      expect(circle_with_non_positive_diameter.errors.attribute_names).to include(:diameter)
    end
  end

  describe "business rules" do
    context "fit inside frame" do
      it "allows a circle that fits and may touch the frame edges" do
        small_frame = create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        circle = build(:circle, frame: small_frame, center_x: 0, center_y: 0, diameter: 10)
        expect(circle).to be_valid
      end

      it "rejects a circle that exceeds the frame" do
        small_frame = create(:frame, center_x: 0, center_y: 0, width: 10, height: 10)
        circle = build(:circle, frame: small_frame, center_x: 5.1, center_y: 0, diameter: 10)
        expect(circle).to be_invalid
        expect(circle.errors[:base]).to include("circle must be fully inside the frame")
      end
    end

    context "no touch / no overlap between circles in the same frame" do
      it "rejects circles that touch" do
        big_frame = create(:frame, center_x: 0, center_y: 0, width: 100, height: 100)
        create(:circle, frame: big_frame, center_x: 0, center_y: 0, diameter: 10)
        touching_circle = build(:circle, frame: big_frame, center_x: 10, center_y: 0, diameter: 10)
        expect(touching_circle).to be_invalid
        expect(touching_circle.errors[:base]).to include("circles cannot touch or overlap within the same frame")
      end

      it "rejects circles that overlap" do
        big_frame = create(:frame, center_x: 0, center_y: 0, width: 100, height: 100)
        create(:circle, frame: big_frame, center_x: 0, center_y: 0, diameter: 10)
        overlapping_circle = build(:circle, frame: big_frame, center_x: 9.5, center_y: 0, diameter: 10)
        expect(overlapping_circle).to be_invalid
        expect(overlapping_circle.errors[:base]).to include("circles cannot touch or overlap within the same frame")
      end

      it "allows minimum positive separation (epsilon = 0.001)" do
        big_frame = create(:frame, center_x: 0, center_y: 0, width: 100, height: 100)
        create(:circle, frame: big_frame, center_x: 0, center_y: 0, diameter: 10)
        separated_circle = build(:circle, frame: big_frame, center_x: 10.001, center_y: 0, diameter: 10)
        expect(separated_circle).to be_valid
      end
    end

    context "updates" do
      it "remains valid when updated within frame" do
        frame  = create(:frame, center_x: 0, center_y: 0, width: 20, height: 20)
        circle = create(:circle, frame: frame, center_x: 0, center_y: 0, diameter: 6)
        circle.assign_attributes(diameter: 8)
        expect(circle).to be_valid
      end

      it "becomes invalid when update makes it exceed the frame" do
        frame  = create(:frame, center_x: 0, center_y: 0, width: 20, height: 20)
        circle = create(:circle, frame: frame, center_x: 0, center_y: 0, diameter: 6)
        circle.assign_attributes(center_x: 10.1)
        expect(circle).to be_invalid
        expect(circle.errors[:base]).to include("circle must be fully inside the frame")
      end
    end
  end
end
