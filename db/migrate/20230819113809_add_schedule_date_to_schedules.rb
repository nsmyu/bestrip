class AddScheduleDateToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :schedule_date, :date
  end
end
