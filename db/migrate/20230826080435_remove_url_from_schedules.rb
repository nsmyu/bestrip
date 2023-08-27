class RemoveUrlFromSchedules < ActiveRecord::Migration[7.0]
  def change
    remove_column :schedules, :url, :string
    remove_column :schedules, :note, :text
  end
end
