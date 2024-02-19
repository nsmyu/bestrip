class ChangeInvitationsToPendingInvitations < ActiveRecord::Migration[7.0]
  def change
    rename_table :invitations, :pending_invitations
  end
end
