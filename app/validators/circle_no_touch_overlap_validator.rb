# frozen_string_literal: true

class CircleNoTouchOverlapValidator < ActiveModel::Validator
  def validate(record)
    return unless record.frame_id.present? &&
                  record.diameter.present? &&
                  record.center_x.present? &&
                  record.center_y.present?

    r     = record.diameter.to_d / 2
    min_x = record.center_x.to_d - r
    max_x = record.center_x.to_d + r
    min_y = record.center_y.to_d - r
    max_y = record.center_y.to_d + r

    candidates = Circle
      .where(frame_id: record.frame_id)
      .where.not(id: record.id)
      .where(<<~SQL, min_x:, max_x:, min_y:, max_y:)
        NOT (
          :max_x < (center_x - diameter/2.0) OR
          :min_x > (center_x + diameter/2.0) OR
          :max_y < (center_y - diameter/2.0) OR
          :min_y > (center_y + diameter/2.0)
        )
      SQL

    cx = record.center_x.to_d
    cy = record.center_y.to_d

    candidates.find_each do |other|
      sum_r = r + (other.diameter.to_d / 2)
      dx = cx - other.center_x.to_d
      dy = cy - other.center_y.to_d
      if (dx * dx + dy * dy) <= (sum_r * sum_r)
        record.errors.add(:base, "circles cannot touch or overlap within the same frame")
        break
      end
    end
  end
end
