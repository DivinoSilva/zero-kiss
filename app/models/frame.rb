# frozen_string_literal: true

class Frame < ApplicationRecord
  has_many :circles, dependent: :restrict_with_error

  validates :center_x, :center_y, :width, :height, presence: true
  validates :width, :height, numericality: { greater_than: 0 }
end