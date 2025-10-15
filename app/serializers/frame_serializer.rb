# frozen_string_literal: true

class FrameSerializer < ActiveModel::Serializer
  attributes :id, :center_x, :center_y, :width, :height, :circles_count,
             :topmost_circle, :bottommost_circle, :leftmost_circle, :rightmost_circle

  has_many :circles

  def center_x = object.center_x.to_f
  def center_y = object.center_y.to_f
  def width    = object.width.to_f
  def height   = object.height.to_f

  def circles_count = object.circles_count

  def topmost_circle     = serialize_circle(object.topmost_circle)
  def bottommost_circle  = serialize_circle(object.bottommost_circle)
  def leftmost_circle    = serialize_circle(object.leftmost_circle)
  def rightmost_circle   = serialize_circle(object.rightmost_circle)

  private

  def serialize_circle(circle)
    return nil unless circle

    CircleSerializer.new(circle).as_json
  end
end
