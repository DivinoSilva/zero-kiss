class AddEdgesToCircles < ActiveRecord::Migration[7.2]
  def change
    execute <<~SQL
      ALTER TABLE circles
      ADD COLUMN top_edge    numeric GENERATED ALWAYS AS (center_y + diameter/2.0) STORED,
      ADD COLUMN bottom_edge numeric GENERATED ALWAYS AS (center_y - diameter/2.0) STORED,
      ADD COLUMN right_edge  numeric GENERATED ALWAYS AS (center_x + diameter/2.0) STORED,
      ADD COLUMN left_edge   numeric GENERATED ALWAYS AS (center_x - diameter/2.0) STORED;
    SQL

    add_index :circles, [:frame_id, :top_edge]
    add_index :circles, [:frame_id, :bottom_edge]
    add_index :circles, [:frame_id, :right_edge]
    add_index :circles, [:frame_id, :left_edge]
  end
end
