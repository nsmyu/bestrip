class DeviseMailer < Devise::Mailer
  default from: email_address_with_name('bestrip2024@gmail.com', 'BesTrip')

  def invitation_instructions(record, token, opts = {})
    opts[:subject] = "#{User.find(record.invited_by_id).name}さんがあなたを旅のメンバーに招待しています"
    @itinerary = Itinerary.find(record.latest_invitation_to)
    super
  end
end
