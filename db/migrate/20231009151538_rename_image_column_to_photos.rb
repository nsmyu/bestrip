class RenameImageColumnToPhotos < ActiveRecord::Migration[7.0]
  def change
    rename_column :photos, :image, :url
  end
end
