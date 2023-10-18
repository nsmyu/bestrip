class AddItineraryPublicToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :itinerary_public, :boolean, default: true, null: false
  end
end
