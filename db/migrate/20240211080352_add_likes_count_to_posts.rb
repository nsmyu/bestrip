class AddLikesCountToPosts < ActiveRecord::Migration[7.0]
  def self.up
    add_column :posts, :likes_count, :integer, null: false, default: 0
  end

  def self.down
    remove_column :posts, :likes_count
  end
end
