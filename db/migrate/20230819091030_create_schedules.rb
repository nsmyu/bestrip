class CreateSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :schedules do |t|
      t.string :title, null: false
      t.time :start_at
      t.time :end_at
      t.string :icon
      t.string :url
      t.string :address
      t.text :note
      t.string :image
      t.references :itinerary, null: false, foreign_key: true

      t.timestamps
    end
  end
end
