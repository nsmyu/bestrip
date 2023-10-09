class RemovePhotosFromPosts < ActiveRecord::Migration[7.0]
  def change
    remove_column :posts, :photos, :json
  end
end
