class CreateFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :favorites do |t|
      t.string :place_id, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :favorites, [:place_id, :user_id], unique: true
  end
end
