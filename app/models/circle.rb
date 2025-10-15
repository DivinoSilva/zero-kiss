# frozen_string_literal: true

class Circle < ApplicationRecord
  belongs_to :frame

  validates :center_x, :center_y, :diameter, presence: true
  validates :diameter, numericality: { greater_than: 0 }

  validates_with CircleFitsFrameValidator
  validates_with CircleNoTouchOverlapValidator
end
