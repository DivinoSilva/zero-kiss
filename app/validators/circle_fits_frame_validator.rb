# frozen_string_literal: true

class CircleFitsFrameValidator < ActiveModel::Validator
  def validate(record)
    frame = record.frame
    return unless frame && record.center_x && record.center_y && record.diameter

    r  = record.diameter.to_d / 2
    cx = record.center_x.to_d
    cy = record.center_y.to_d

    fx_min = frame.center_x.to_d - frame.width.to_d  / 2
    fx_max = frame.center_x.to_d + frame.width.to_d  / 2
    fy_min = frame.center_y.to_d - frame.height.to_d / 2
    fy_max = frame.center_y.to_d + frame.height.to_d / 2

    if (cx - r) < fx_min || (cx + r) > fx_max || (cy - r) < fy_min || (cy + r) > fy_max
      record.errors.add(:base, "circle must be fully inside the frame")
    end
  end
end
