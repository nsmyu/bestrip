class ChangePostImagesToPhotos < ActiveRecord::Migration[7.0]
  def change
    rename_table :post_images, :photos
  end
end
