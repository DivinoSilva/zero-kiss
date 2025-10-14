class AddRangesAndExclusionConstraintToFrames < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE frames
          ADD COLUMN x_range numrange
            GENERATED ALWAYS AS (
              numrange((center_x - width/2.0)::numeric, (center_x + width/2.0)::numeric, '[]')
            ) STORED,
          ADD COLUMN y_range numrange
            GENERATED ALWAYS AS (
              numrange((center_y - height/2.0)::numeric, (center_y + height/2.0)::numeric, '[]')
            ) STORED;
        SQL

        execute <<~SQL
          ALTER TABLE frames
          ADD CONSTRAINT frames_no_touch_or_overlap
          EXCLUDE USING gist (
            x_range WITH &&,
            y_range WITH &&
          );
        SQL
      end

      dir.down do
        execute "ALTER TABLE frames DROP CONSTRAINT IF EXISTS frames_no_touch_or_overlap;"
        execute "ALTER TABLE frames DROP COLUMN IF EXISTS x_range, DROP COLUMN IF EXISTS y_range;"
      end
    end
  end
end
