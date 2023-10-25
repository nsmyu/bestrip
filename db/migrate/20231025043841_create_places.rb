class CreatePlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :places do |t|
      t.string :place_id, null: false
      t.references :placeable, polymorphic: true, null: false

      t.timestamps
    end
    add_index :places, [:place_id, :placeable_type, :placeable_id], unique: true
  end
end
