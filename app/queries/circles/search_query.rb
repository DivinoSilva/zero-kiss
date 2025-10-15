# frozen_string_literal: true

module Circles
  class SearchQuery
    def self.call(filters)
      rel = Circle.all
      rel = rel.where(frame_id: filters[:frame_id]) if filters[:frame_id].present?

      if filters[:center_x].present? && filters[:center_y].present? && filters[:radius].present?
        cx = BigDecimal(filters[:center_x].to_s)
        cy = BigDecimal(filters[:center_y].to_s)
        r  = BigDecimal(filters[:radius].to_s)

        min_x, max_x = cx - r, cx + r
        min_y, max_y = cy - r, cy + r

        rel = rel.where(<<~SQL, min_x:, max_x:, min_y:, max_y:)
          NOT (
            :max_x < (center_x - diameter/2.0) OR
            :min_x > (center_x + diameter/2.0) OR
            :max_y < (center_y - diameter/2.0) OR
            :min_y > (center_y + diameter/2.0)
          )
        SQL

        rel = rel.where(<<~SQL, cx: cx.to_f, cy: cy.to_f, r: r.to_f)
          ( (:r - diameter/2.0) >= 0 ) AND
          ( (center_x - :cx)^2 + (center_y - :cy)^2 ) <= (:r - diameter/2.0)^2
        SQL
      end

      rel
    end
  end
end
