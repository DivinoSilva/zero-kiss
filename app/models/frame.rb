# frozen_string_literal: true

class Frame < ApplicationRecord
  has_many :circles, dependent: :restrict_with_error

  validates :center_x, :center_y, :width, :height, presence: true
  validates :width, :height, numericality: { greater_than: 0 }

  accepts_nested_attributes_for :circles, allow_destroy: false

  def circles_count = circles.count
  def topmost_circle    = circles.order(top_edge: :desc).first
  def bottommost_circle = circles.order(bottom_edge: :asc).first
  def rightmost_circle  = circles.order(right_edge: :desc).first
  def leftmost_circle   = circles.order(left_edge: :asc).first
end
