# frozen_string_literal: true

class Frame < ApplicationRecord
  validates :center_x, :center_y, :width, :height, presence: true
  validates :width, :height, numericality: { greater_than: 0 }
end