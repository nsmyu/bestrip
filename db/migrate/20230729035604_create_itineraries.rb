class CreateItineraries < ActiveRecord::Migration[7.0]
  def change
    create_table :itineraries do |t|
      t.string :name,         null: false
      t.string :image
      t.date :departure_date, null: false
      t.date :return_date,    null: false
      t.integer :user_id,     null: false

      t.timestamps
    end
  end
end
