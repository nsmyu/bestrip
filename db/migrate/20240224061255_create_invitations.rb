class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :pending_invitations do |t|
      t.references :itinerary, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :code, limit: 22

      t.timestamps
    end
    add_index :pending_invitations, [:user_id, :itinerary_id], unique: true
    add_index :pending_invitations, :code, unique: true
  end
end
