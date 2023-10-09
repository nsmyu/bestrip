class RemoveForeignKeyFromPosts < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :posts, :itinerary_users, column: :itinerary_users_id
    remove_column :posts, :itinerary_users_id
  end
end
