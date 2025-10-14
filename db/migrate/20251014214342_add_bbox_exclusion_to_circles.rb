class AddBboxExclusionToCircles < ActiveRecord::Migration[7.2]
  def change
    enable_extension "btree_gist" unless extension_enabled?("btree_gist")

    execute <<~SQL
      ALTER TABLE circles
      ADD COLUMN x_range numrange
        GENERATED ALWAYS AS (
          numrange((center_x - diameter/2.0)::numeric, (center_x + diameter/2.0)::numeric, '[]')
        ) STORED,
      ADD COLUMN y_range numrange
        GENERATED ALWAYS AS (
          numrange((center_y - diameter/2.0)::numeric, (center_y + diameter/2.0)::numeric, '[]')
        ) STORED;
    SQL

    execute <<~SQL
      ALTER TABLE circles
      ADD CONSTRAINT circles_no_touch_or_overlap_bbox
      EXCLUDE USING gist (
        frame_id WITH =,
        x_range  WITH &&,
        y_range  WITH &&
      );
    SQL
  end
end
