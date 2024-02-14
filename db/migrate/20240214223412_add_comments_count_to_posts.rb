class AddCommentsCountToPosts < ActiveRecord::Migration[7.0]
  def self.up
    add_column :posts, :comments_count, :integer, null: false, default: 0
  end

  def self.down
    remove_column :posts, :comments_count
  end
end
