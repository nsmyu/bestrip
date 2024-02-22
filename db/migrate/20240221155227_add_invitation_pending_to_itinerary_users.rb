class AddInvitationPendingToItineraryUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :itinerary_users, :confirmed, :boolean, default: true, null: false
  end
end
