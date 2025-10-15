class CreateCircles < ActiveRecord::Migration[7.2]
  def change
    create_table :circles do |t|
      t.references :frame, null: false, foreign_key: true
      t.decimal :center_x, precision: 12, scale: 3, null: false
      t.decimal :center_y, precision: 12, scale: 3, null: false
      t.decimal :diameter, precision: 12, scale: 3, null: false

      t.timestamps
    end

    add_index :circles, [:frame_id, :center_x, :center_y]
    add_check_constraint :circles, "diameter > 0", name: "circles_diameter_positive"
  end
end
