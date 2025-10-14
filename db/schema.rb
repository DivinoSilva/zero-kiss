# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_10_14_184217) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "frames", force: :cascade do |t|
    t.decimal "center_x", precision: 12, scale: 3, null: false
    t.decimal "center_y", precision: 12, scale: 3, null: false
    t.decimal "width", precision: 12, scale: 3, null: false
    t.decimal "height", precision: 12, scale: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "x_range", type: :numrange, as: "numrange((center_x - (width / 2.0)), (center_x + (width / 2.0)), '[]'::text)", stored: true
    t.virtual "y_range", type: :numrange, as: "numrange((center_y - (height / 2.0)), (center_y + (height / 2.0)), '[]'::text)", stored: true
    t.index ["center_x", "center_y"], name: "index_frames_on_center_x_and_center_y"
    t.index ["width", "height"], name: "index_frames_on_width_and_height"
    t.exclusion_constraint "x_range WITH &&, y_range WITH &&", using: :gist, name: "frames_no_touch_or_overlap"
  end
end
