class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.json :photos, null: false
      t.text :caption
      t.references :itinerary_users, null: false, foreign_key: true

      t.timestamps
    end
  end
end
