class AddItineraryPublicToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :itinerary_public, :boolean, default: false, null: false
  end
end
