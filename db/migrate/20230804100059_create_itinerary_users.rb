class CreateItineraryUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :itinerary_users do |t|
      t.references :itinerary, null: false, foreign_key: true
      t.references :user,      null: false, foreign_key: true

      t.timestamps
    end
  end
end
