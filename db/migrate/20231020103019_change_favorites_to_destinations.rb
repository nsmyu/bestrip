class ChangeFavoritesToDestinations < ActiveRecord::Migration[7.0]
  def change
    rename_table 'favorites', 'destinations'
  end
end
