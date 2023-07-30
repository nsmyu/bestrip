class RenameNameColumnToItineraries < ActiveRecord::Migration[7.0]
  def change
    rename_column :itineraries, :name, :title
  end
end
