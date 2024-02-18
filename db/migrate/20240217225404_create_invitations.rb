class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations do |t|
      t.references :user, null: false
      t.references :itinerary, null: false

      t.timestamps
    end
  end
end
