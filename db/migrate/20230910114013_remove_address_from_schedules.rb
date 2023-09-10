class RemoveAddressFromSchedules < ActiveRecord::Migration[7.0]
  def change
    remove_column :schedules, :address, :string
    remove_column :schedules, :image, :string
    remove_column :schedules, :place_name, :string
  end
end
