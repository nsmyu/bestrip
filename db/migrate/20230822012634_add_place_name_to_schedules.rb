class AddPlaceNameToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :place_name, :string
  end
end
