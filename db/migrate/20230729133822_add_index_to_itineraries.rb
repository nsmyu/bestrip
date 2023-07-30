class AddIndexToItineraries < ActiveRecord::Migration[7.0]
  def change
    add_index :itineraries, [:name, :user_id], unique: true
  end
end
