#frozen_string_literal: true

class FrameSerializer < ActiveModel::Serializer
  attributes :id, :center_x, :center_y, :width, :height

  def center_x = object.center_x.to_f
  def center_y = object.center_y.to_f
  def width    = object.width.to_f
  def height   = object.height.to_f
end
