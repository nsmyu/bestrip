class AddNoteToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :note, :text
  end
end
