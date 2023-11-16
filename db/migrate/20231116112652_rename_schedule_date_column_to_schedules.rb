class RenameScheduleDateColumnToSchedules < ActiveRecord::Migration[7.0]
  def change
    rename_column :schedules, :schedule_date, :date
  end
end
