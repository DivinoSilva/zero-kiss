class CreateFrames < ActiveRecord::Migration[7.2]
  def change
    create_table :frames do |t|
      t.decimal :center_x, precision: 12, scale: 3, null: false
      t.decimal :center_y, precision: 12, scale: 3, null: false
      t.decimal :width, precision: 12, scale: 3, null: false
      t.decimal :height, precision: 12, scale: 3, null: false

      t.timestamps
    end


    add_index :frames, %i[center_x center_y]
    add_index :frames, %i[width height]
  end
end