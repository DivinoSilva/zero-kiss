# frozen_string_literal: true

module Circles
  class SearchQuery
    def self.call(filters)
      rel = Circle.all
      rel = rel.where(frame_id: filters[:frame_id]) if filters[:frame_id].present?

      cx = filters[:center_x]
      cy = filters[:center_y]
      r  = filters[:radius]

      return rel unless cx.present? && cy.present? && r.present?

      cx = BigDecimal(cx.to_s)
      cy = BigDecimal(cy.to_s)
      r  = BigDecimal(r.to_s)

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

      rel.where(<<~SQL, cx: cx.to_f, cy: cy.to_f, r: r.to_f)
        (:r - diameter/2.0) >= 0 AND
        ((center_x - :cx)*(center_x - :cx) + (center_y - :cy)*(center_y - :cy))
          <= (:r - diameter/2.0)*(:r - diameter/2.0)
      SQL
    end
  end
end
