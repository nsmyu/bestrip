class AddIndexToPosts < ActiveRecord::Migration[7.0]
  def change
    change_column :posts, :user_id, :bigint, null: false
    change_column :posts, :itinerary_id, :bigint, null: false
    add_index :posts, :user_id
    add_index :posts, :itinerary_id
  end
end
