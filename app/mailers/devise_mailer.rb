class DeviseMailer < Devise::Mailer
  default from: email_address_with_name('bestrip2024@gmail.com', 'BesTrip')

  def invitation_instructions(record, token, opts = {})
    opts[:subject] = "#{User.find(record.invited_by_id).name}さんがあなたを旅のメンバーに招待しています"
    @itinerary = Itinerary.find(record.currently_invited_to)
    @invitation = @itinerary.invitations.find_by(user_id: record.id)
    super
  end
end
