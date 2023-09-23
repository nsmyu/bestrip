class CreateFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :favorites do |t|
      t.string :place_id, null: false
      t.references :itinerary, null: false, foreign_key: true

      t.timestamps
    end
  end
end
