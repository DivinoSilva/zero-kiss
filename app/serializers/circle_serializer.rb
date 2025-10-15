# frozen_string_literal: true

class CircleSerializer < ActiveModel::Serializer
  attributes :id, :frame_id, :center_x, :center_y, :diameter

  def center_x = object.center_x.to_f
  def center_y = object.center_y.to_f
  def diameter = object.diameter.to_f
end
