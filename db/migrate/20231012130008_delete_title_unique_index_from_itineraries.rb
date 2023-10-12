class DeleteTitleUniqueIndexFromItineraries < ActiveRecord::Migration[7.0]
  def change
    remove_index :itineraries, [:title, :user_id]
  end
end
