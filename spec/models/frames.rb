# frozen_string_literal: true

require "rails_helper"

RSpec.describe Frame, type: :model do
  describe "validations" do
    it "requires center_x, center_y, width, height" do
      frame = build(:frame, center_x: nil, center_y: nil, width: nil, height: nil)
      expect(frame).to be_invalid
      expect(frame.errors.keys).to include(:center_x, :center_y, :width, :height)
    end

    it "requires width and height to be positive" do
      frame = build(:frame, width: 0, height: -1)
      expect(frame).to be_invalid
      expect(frame.errors[:width]).to be_present
      expect(frame.errors[:height]).to be_present
    end
  end

  describe "exclusion constraint (no touch / no overlap)" do
    let!(:base) { create(:frame, center_x: 0, center_y: 0, width: 10, height: 10) }

    context "on create" do
      it "rejects edge-touching rectangles (same y, adjacent x)" do
        expect {
          create(:frame, center_x: 10, center_y: 0, width: 10, height: 10)
        }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it "rejects corner-touching rectangles" do
        expect {
          create(:frame, center_x: 10, center_y: 10, width: 10, height: 10)
        }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it "rejects overlapping rectangles" do
        expect {
          create(:frame, center_x: 4, center_y: 0, width: 10, height: 10)
        }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it "allows strict separation" do
        expect {
          create(:frame, center_x: 11, center_y: 0, width: 10, height: 10)
        }.not_to raise_error
      end
    end

    context "on update" do
      it "rejects moving a frame to touch an existing one" do
        other = create(:frame, center_x: 20, center_y: 0, width: 10, height: 10)
        expect {
          other.update!(center_x: 10, center_y: 0)
        }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it "rejects moving a frame to overlap an existing one" do
        other = create(:frame, center_x: 20, center_y: 0, width: 10, height: 10)
        expect {
          other.update!(center_x: 4, center_y: 0)
        }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
