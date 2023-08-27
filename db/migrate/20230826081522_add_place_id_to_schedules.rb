class AddPlaceIdToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :place_id, :string
  end
end
