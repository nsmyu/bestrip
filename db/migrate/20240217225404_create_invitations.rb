class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :itinerary, null: false, foreign_key: true

      t.timestamps
    end
    add_index :invitations, [:user_id, :itinerary_id], unique: true
  end
end
