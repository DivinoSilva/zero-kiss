# frozen_string_literal: true

module Circles
  class SearchQuery
    def self.call(params)
      rel = Circle.all
      rel = rel.where(frame_id: params[:frame_id]) if params[:frame_id].present?

      if params[:center_x].present? && params[:center_y].present? && params[:radius].present?
        cx = BigDecimal(params[:center_x].to_s)
        cy = BigDecimal(params[:center_y].to_s)
        r  = BigDecimal(params[:radius].to_s)
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
      end

      rel
    end
  end
end
