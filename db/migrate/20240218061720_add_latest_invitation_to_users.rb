class AddLatestInvitationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :latest_invitation_to, :bigint
  end
end
