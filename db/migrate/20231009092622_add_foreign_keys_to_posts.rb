class AddForeignKeysToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :user_id, :integer
    add_column :posts, :itinerary_id, :integer
    add_foreign_key :posts, :users
    add_foreign_key :posts, :itineraries
  end
end
