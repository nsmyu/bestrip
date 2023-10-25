class CreatePlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :places do |t|
      t.string :place_id, null: false
      t.references :placable, polymorphic: true, null: false

      t.timestamps
    end
    add_index :places, [:place_id, :placable_type, :placable_id], unique: true
  end
end
