# frozen_string_literal: true
require "rails_helper"

RSpec.describe Circles::SearchQuery do
  let!(:frame_a) { create(:frame, center_x: 0,   center_y: 0,   width: 100, height: 100) }
  let!(:frame_b) { create(:frame, center_x: 101, center_y: 101, width: 100, height: 100) }

  let!(:c1) { create(:circle, frame: frame_a, center_x: 0,   center_y: 0,   diameter: 10) }
  let!(:c2) { create(:circle, frame: frame_a, center_x: 8,   center_y: 0,   diameter: 4) }
  let!(:c3) { create(:circle, frame: frame_b, center_x: 101, center_y: 101, diameter: 4) }

  it "returns all circles when no filters are provided" do
    rel = described_class.call({})
    expect(rel.pluck(:id)).to match_array([c1.id, c2.id, c3.id])
  end

  it "filters by frame_id" do
    rel = described_class.call(frame_id: frame_a.id)
    expect(rel.pluck(:id)).to match_array([c1.id, c2.id])
  end

  it "returns circles whose whole area fits within the given radius (center within r - d/2)" do
    rel = described_class.call(center_x: 0, center_y: 0, radius: 7)
    expect(rel.pluck(:id)).to contain_exactly(c1.id)
  end

  it "excludes circles when radius < diameter/2" do
    rel = described_class.call(center_x: 0, center_y: 0, radius: 1)
    expect(rel).to be_empty
  end

  it "includes circle on exact boundary (<= check)" do
    rel = described_class.call(center_x: 8, center_y: 0, radius: 2)
    expect(rel.pluck(:id)).to include(c2.id)
  end
end
